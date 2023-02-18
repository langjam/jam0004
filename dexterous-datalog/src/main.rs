use chumsky::Parser;
use miette::{
    miette, Diagnostic, GraphicalReportHandler, IntoDiagnostic, NamedSource, Report, Result,
};
use rustyline::{error::ReadlineError, Editor};
use std::fs;

mod data_set;
mod error;
mod parser;

use data_set::DataSet;
use error::Error;
use parser::{program, repl};

fn main() -> Result<()> {
    let args: Vec<_> = std::env::args().collect();

    if args.len() != 2 {
        return Err(miette!("expected exactly one argument for input file"));
    }

    let filename = &args[1];
    let input = fs::read_to_string(filename).into_diagnostic()?;

    let _program = program().parse(input.as_str()).map_err(|errors| {
        Report::from(Error::from(errors)).with_source_code(NamedSource::new(&filename, input))
    })?;

    let mut _data = DataSet::default();
    // add program to data here

    let mut rl = Editor::<()>::new().into_diagnostic()?;
    let mut line_count = 1;
    let handler = GraphicalReportHandler::new();

    loop {
        let line = rl.readline("?- ");

        match line {
            Ok(line) => {
                if let Err(error) = repl_step(&line) {
                    if line == "quit" || line == "exit" {
                        println!("hint: use control-d to leave");
                    }

                    let mut buf = String::new();
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

fn repl_step(input: &str) -> Result<(), Error> {
    let syntax = repl()
        .parse(input)
        .map_err(|errors| (Error::from(errors)))?;

    println!("{:#?}", syntax);

    Ok(())
}

pub fn is_sinister(c: char) -> bool {
    r#"qwertasdfgzxcvbQWERTASDFGZXCVB12345!@#$%~`"#.contains(c)
}
