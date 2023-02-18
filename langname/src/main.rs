use miette::{miette, IntoDiagnostic, Result};
use std::fs;

mod parser;

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

    println!("{:#?}", syntax);
    println!("{:?}", context.names.iter().enumerate().collect::<Vec<_>>());

    Ok(())
}

pub fn is_sinister(c: char) -> bool {
    "qwertasdfgzxcvbQWERTASDFGZXCVB12345!@#$%~`".contains(c)
}
