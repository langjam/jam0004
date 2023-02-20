use chumsky::Parser as ChumskyParser;
use clap::Parser;

use miette::{Diagnostic, GraphicalReportHandler, IntoDiagnostic, NamedSource, Report, Result};
use rustyline::{error::ReadlineError, Editor};
use std::{ffi::OsString, fs};

mod data_set;
mod error;
mod parser;

use data_set::DataSet;
use error::Error;
use parser::Repl;

#[derive(Debug, clap::Parser)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// The name of an input file to load as a set of facts.
    #[arg()]
    filename: Option<OsString>,

    /// A query to run. If this is not specified, a repl is started.
    #[arg(short, long)]
    query: Option<String>,
}

fn main() -> Result<()> {
    let args = Args::parse();

    let mut data = DataSet::default();

    if let Some(filename) = args.filename.as_deref() {
        let input = fs::read_to_string(filename).into_diagnostic()?;

        let program = parser::program().parse(input.as_str()).map_err(|errors| {
            Report::from(Error::from(errors))
                .with_source_code(NamedSource::new(filename.to_string_lossy(), input))
        })?;

        data.add_program(&program)?;

        if args.query.is_none() {
            println!(
                "...loaded file {} successfully.",
                filename.to_string_lossy()
            );
        }
    }

    data.run();

    if let Some(query) = args.query {
        cli_query(query, data)
    } else {
        repl(data)
    }
}

fn cli_query(query: String, mut data: DataSet) -> Result<()> {
    let query = parser::query_no_prompt()
        .parse(query.as_str())
        .map_err(|errors| {
            Report::from(Error::from(errors)).with_source_code(NamedSource::new("--query", query))
        })?;

    data.run_query(&query)?;
    Ok(())
}

fn repl(mut data: DataSet) -> Result<()> {
    let mut rl = Editor::<()>::new().into_diagnostic()?;
    let mut line_count = 1;
    let handler = GraphicalReportHandler::new();

    loop {
        let line = rl.readline(">> ");
        let mut buf = String::new();

        match line {
            Ok(line) => {
                if let Err(error) = repl_step(&line, &mut data) {
                    if line == "quit" || line == "exit" {
                        println!("hint: use control-d to leave");
                    }

                    buf.clear();
                    let diagnostic = error
                        .with_source_code(NamedSource::new(format!("<repl:{line_count}>"), line));
                    let _ = handler.render_report(&mut buf, &diagnostic as &dyn Diagnostic);

                    println!("{}", buf);
                }

                line_count += 1;
            }

            // Control-C goes back to fresh prompt, like in the shell.
            Err(ReadlineError::Interrupted) => {
                continue;
            }

            // Control-D quits
            Err(ReadlineError::Eof) => {
                println!("goodbye!");
                return Ok(());
            }

            Err(e) => {
                return Err(e).into_diagnostic();
            }
        }
    }
}

fn repl_step(input: &str, data: &mut DataSet) -> Result<(), Error> {
    let syntax = parser::repl()
        .parse(input)
        .map_err(|errors| (Error::from(errors)))?;

    match syntax {
        Repl::Program(p) => data.add_program(&p),
        Repl::Query(q) => data.run_query(&q),
    }
}
