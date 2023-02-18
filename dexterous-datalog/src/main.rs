use miette::{miette, IntoDiagnostic, Report, Result};
use rustyline::{error::ReadlineError, Editor};
use std::fs;

mod data_set;
mod parser;

use data_set::*;
use parser::*;

fn main() -> Result<()> {
    let args: Vec<_> = std::env::args().collect();

    if args.len() != 2 {
        return Err(miette!("expected exactly one argument for input file"));
    }

    let filename = &args[1];
    let input = fs::read_to_string(filename).into_diagnostic()?;

    let mut context = Context::new(&input);
    let syntax = parse(&input, &mut context)?;

    let mut data = DataSet::new(&syntax, &context)?;

    let mut rl = Editor::<()>::new().into_diagnostic()?;

    loop {
        let line = rl.readline("?- ");

        match line {
            Ok(line) => {
                repl_step(&line, &mut context);
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

fn repl_step(input: &str, context: &mut Context) {
    if let Err(e) = repl_step_inner(input, context) {
        println!("{}", Report::from(e));
    }
}

fn repl_step_inner(input: &str, context: &mut Context) -> Result<()> {
    // I'll have to use a few more Strings in Context for this...
    // let query = parse_query(input, context)?;
    // println!("{:#?}", query);
    Ok(())
}

pub fn is_sinister(c: char) -> bool {
    "qwertasdfgzxcvbQWERTASDFGZXCVB12345!@#$%~`".contains(c)
}
