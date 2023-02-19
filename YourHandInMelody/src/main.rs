use anyhow::{anyhow, bail};
use inkwell::context::Context;
use std::borrow::Cow;
use std::fs::File;
use std::path::{Path, PathBuf};
use std::process::exit;

pub mod compile;
pub mod parser;
pub mod yihmstd;

use clap::{Parser, ValueEnum};
use hound::WavSpec;
use inkwell::execution_engine::JitFunction;
use inkwell::OptimizationLevel;
use crate::compile::llvm::LLVMCompiler;
use crate::yihmstd::{add_symbols, SAMPLE_RATE, SoundRecv};

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
    eprintln!("{}: {}", file.to_string_lossy(), err);
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
        eprintln!("fatal error: no input files");
        exit(1);
    }

    let mut has_error = false;
    macro_rules! bail_if_errors {
        () => {
            if has_error {
                eprintln!("errors occurred, exiting");
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
    let ll_cc = LLVMCompiler::new(cc, &module);
    ll_cc.compile().unwrap();

    match args.emit {
        Emit::Llvm => {
            report_any_errors(main_file, || {
                let mut buf = main_file.clone();
                if !buf.set_extension("ll") {
                    bail!("could not decide on output file, please specify manually");
                }
                module
                    .print_to_file(&buf)
                    .map_err(|err| anyhow!("{}", err))?;
                eprintln!("wrote to file: {}", buf.to_string_lossy());
                Ok(())
            });
        }
        Emit::Sound => {
            report_any_errors(main_file, || {
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

                let mut writer = hound::WavWriter::create(&file, WavSpec {
                    channels: 2,
                    sample_rate: SAMPLE_RATE,
                    bits_per_sample: 32,
                    sample_format: hound::SampleFormat::Float,
                })?;
                for s in buf {
                    writer.write_sample(s.0 as f32)?;
                    writer.write_sample(s.1 as f32)?;
                }
                writer.finalize()?;
                eprintln!("wrote to file: {}", file.to_string_lossy());
                Ok(())
            });
        }
    }
}
