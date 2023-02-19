use anyhow::{anyhow, bail};
use inkwell::context::Context;
use std::borrow::Cow;
use std::fs::File;
use std::io::{BufRead, BufReader, Read, Seek, SeekFrom};
use std::path::{Path, PathBuf};
use std::process::exit;

pub mod compile;
pub mod parser;
pub mod yihmstd;

use crate::compile::llvm::LLVMCompiler;
use crate::parser::SourcedError;
use crate::yihmstd::{add_symbols, SoundRecv, SAMPLE_RATE};
use clap::{Parser, ValueEnum};
use colored::Colorize;
use hound::WavSpec;
use inkwell::debug_info::{DWARFEmissionKind, DWARFSourceLanguage};
use inkwell::execution_engine::JitFunction;
use inkwell::OptimizationLevel;

#[derive(Parser, Debug)]
struct Args {
    /// The list of files to compile.
    files: Vec<PathBuf>,
    #[arg(long, short, value_enum, default_value_t = Emit::Llvm)]
    /// What to output.
    emit: Emit,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum, Debug)]
enum Emit {
    /// Compile the 'main' sound, save it to an audio file.
    Sound,
    /// Compile to LLVM bitcode, and save it to a file.
    Llvm,
}

fn report_error(file: &Path, err: impl Into<anyhow::Error>) {
    let err = err.into();
    match err.downcast::<SourcedError>() {
        Ok(err) => {
            eprintln!("{}: {}", "error".red().bold(), err.msg.bold());
            eprintln!(
                "   {} {}:{}",
                "-->".bright_blue().bold(),
                file.to_string_lossy(),
                err.span.start
            );

            let _ = (|| -> anyhow::Result<()> {
                let mut file = BufReader::new(File::open(file)?);
                let mut pos = file.seek(SeekFrom::Start(err.span.start.pos as u64))?;
                let buf = &mut [0; 16];
                loop {
                    let by = 16.min(pos as i64);
                    pos = file.seek(SeekFrom::Current(-by))?;
                    let truncated = &mut buf[..by as usize];
                    file.read(truncated)?;
                    file.seek(SeekFrom::Current(-by))?;
                    if let Some(i) = buf.iter().rposition(|it| *it == '\n' as u8) {
                        file.seek(SeekFrom::Current(i as i64 + 1))?;
                        break;
                    }
                    if pos == 0 {
                        break;
                    }
                }
                let line_range = err.span.end.line..=err.span.start.line;
                let lines = file
                    .lines()
                    .take((err.span.end.line - err.span.start.line + 1) as usize)
                    .collect::<Result<Vec<_>, _>>()?;
                for (line, l_no) in lines.into_iter().zip(line_range.clone().into_iter()) {
                    let at_start = l_no == *line_range.start();
                    let at_end = l_no == *line_range.end();
                    match (at_start, at_end) {
                        (true, true) => {
                            let codepoints = line.chars().collect::<Vec<char>>();
                            eprintln!(
                                "{} {} {}{}{}",
                                format!("{: >4}", l_no).bright_blue(),
                                "|".bright_blue(),
                                codepoints
                                    .get(0..err.span.start.column as usize - 1)
                                    .ok_or_else(|| anyhow!(""))?
                                    .iter()
                                    .collect::<String>(),
                                codepoints
                                    .get(
                                        err.span.start.column as usize - 1
                                            ..err.span.end.column as usize - 1
                                    )
                                    .ok_or_else(|| anyhow!(""))?
                                    .iter()
                                    .collect::<String>()
                                    .underline()
                                    .red(),
                                codepoints
                                    .get(err.span.end.column as usize - 1..)
                                    .ok_or_else(|| anyhow!(""))?
                                    .iter()
                                    .collect::<String>()
                            );
                        }
                        (false, false) => {
                            eprintln!("     {} {}", "|".bright_blue(), line.red());
                        }
                        (_, _) => {
                            let codepoints = line.chars().collect::<Vec<char>>();
                            let loc = if at_start {
                                &err.span.start
                            } else {
                                &err.span.end
                            };
                            let (lhs, rhs) = if at_start {
                                (
                                    codepoints
                                        .get(..loc.column as usize - 1)
                                        .ok_or_else(|| anyhow!(""))?
                                        .iter()
                                        .collect::<String>()
                                        .normal(),
                                    codepoints
                                        .get(loc.column as usize - 1..)
                                        .ok_or_else(|| anyhow!(""))?
                                        .iter()
                                        .collect::<String>()
                                        .underline()
                                        .red(),
                                )
                            } else {
                                (
                                    codepoints
                                        .get(..loc.column as usize - 2)
                                        .ok_or_else(|| anyhow!(""))?
                                        .iter()
                                        .collect::<String>()
                                        .underline()
                                        .red(),
                                    codepoints
                                        .get(loc.column as usize - 1..)
                                        .ok_or_else(|| anyhow!(""))?
                                        .iter()
                                        .collect::<String>()
                                        .normal(),
                                )
                            };
                            eprintln!(
                                "{} {} {}{}",
                                format!("{: >4}", l_no).bright_blue(),
                                "|".bright_blue(),
                                lhs,
                                rhs
                            );
                        }
                    }
                }
                Ok(())
            })();

            for note in err.notes {
                eprintln!("        {}: {}", note.kind, note.msg);
            }
        }
        Err(err) => {
            eprintln!(
                "{}: {}: {}",
                "error".red().bold(),
                file.to_string_lossy(),
                err
            );
        }
    }
}

fn report_any_errors<T>(file: &Path, f: impl FnOnce() -> anyhow::Result<T>) -> Option<T> {
    match f() {
        Ok(ok) => Some(ok),
        Err(err) => {
            report_error(file, err);
            None
        }
    }
}

fn main() {
    let args: Args = Args::parse();
    if args.files.is_empty() {
        eprintln!("{}: no input files", "fatal error".red().bold());
        exit(1);
    }

    let mut has_error = false;
    macro_rules! bail_if_errors {
        () => {
            if has_error {
                eprintln!("{}", "errors occurred, exiting".red());
                exit(1);
            }
        };
    }
    let mut programs = Vec::new();
    for source in &args.files {
        has_error |= report_any_errors(&source, || {
            let file = File::open(&source)?;
            let mut parser = parser::Parser::new(parser::Lexer::new_from_reader(file));
            let (program, errors) = parser.parse_program().unwrap();
            if !errors.is_empty() {
                has_error = true;
                for err in errors {
                    report_error(&source, err);
                }
            }
            programs.push((source, program));
            Ok(())
        })
        .is_none();
    }
    bail_if_errors!();

    let mut cc = compile::Compiler::default();
    for (src, program) in &programs {
        has_error |= report_any_errors(src, || cc.pre_compile(program)).is_none();
    }
    bail_if_errors!();

    for (src, program) in &programs {
        has_error |= report_any_errors(src, || cc.compile(program)).is_none();
    }
    bail_if_errors!();

    let main_file = &args.files[0];

    let ctx = Context::create();
    let module = ctx.create_module(
        &main_file
            .file_name()
            .map(|it| it.to_string_lossy())
            .unwrap_or_else(|| Cow::from("unknown")),
    );
    module.set_source_file_name(&main_file.to_string_lossy());
    let main_file_dbg = main_file.canonicalize().unwrap_or_else(|_| main_file.clone());
    let mut ll_cc = LLVMCompiler::new(cc, &module);
    let di = ll_cc.module.create_debug_info_builder(
        true,
        DWARFSourceLanguage::C,
        main_file_dbg
            .file_name()
            .map(|it| it.to_string_lossy().to_string())
            .unwrap_or_else(|| "unknown.mel".to_owned())
            .as_str(),
        main_file_dbg
            .parent()
            .map(|it| it.to_string_lossy().to_string())
            .unwrap_or_else(|| "/".to_owned())
            .as_str(),
        "yhim",
        true,
        "",
        0,
        "",
        DWARFEmissionKind::Full,
        0,
        false,
        false,
        "/",
        "yhim",
    );
    ll_cc.dib = Some(di);
    ll_cc.compile().unwrap();

    match args.emit {
        Emit::Llvm => {
            report_any_errors(&main_file, || {
                let mut buf = main_file.clone();
                if !buf.set_extension("ll") {
                    bail!("could not decide on output file, please specify manually");
                }
                module
                    .print_to_file(&buf)
                    .map_err(|err| anyhow!("{}", err))?;
                println!(
                    "{}: {}",
                    "output to file".green().bold(),
                    buf.to_string_lossy()
                );
                Ok(())
            });
        }
        Emit::Sound => {
            report_any_errors(&main_file, || {
                let mut file = main_file.clone();
                if !file.set_extension("wav") {
                    bail!("could not decide on output file, please specify manually");
                }

                add_symbols();
                let jit = module
                    .create_jit_execution_engine(OptimizationLevel::Aggressive)
                    .map_err(|e| anyhow!("{}", e))?;
                let buf = unsafe {
                    let main: JitFunction<unsafe extern "C" fn(SoundRecv) -> ()> =
                        jit.get_function("main_sound")?;
                    let recv = SoundRecv::new();
                    main.call(recv.clone());
                    recv.into_buf()
                };

                let mut writer = hound::WavWriter::create(
                    &file,
                    WavSpec {
                        channels: 2,
                        sample_rate: SAMPLE_RATE,
                        bits_per_sample: 32,
                        sample_format: hound::SampleFormat::Float,
                    },
                )?;
                for s in buf {
                    writer.write_sample(s.0 as f32)?;
                    writer.write_sample(s.1 as f32)?;
                }
                writer.finalize()?;
                println!(
                    "{}: {}",
                    "output to file".green().bold(),
                    file.to_string_lossy()
                );
                Ok(())
            });
        }
    }
}
