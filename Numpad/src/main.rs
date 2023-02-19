/**/

mod common;
mod lexer;
mod machine;
mod parser;

use crate::common::*;
use crate::machine::Machine;

use anyhow::Context;
use clap::Parser;

#[derive(Debug, clap::Parser)]
#[clap(version, propagate_version = true)]
struct Cli {
    /// One or more Numpad source files
    #[clap(value_parser, required(true))]
    filepaths: Vec<std::path::PathBuf>,

    /// Show a lot of intermediate output
    #[clap(short, long)]
    verbose: bool,
}

fn main() -> Result<(), anyhow::Error> {
    let args = Cli::parse();
    let filepath = &args.filepaths.get(0).context("missing argument")?;
    let source = std::fs::read_to_string(&filepath)?;
    let tokens = lexer::lex(&source, args.verbose)?;
    let instructions = parser::parse(tokens, args.verbose)?;
    let output = evaluate(instructions, args.verbose)?;
    println!("Output: {:?}", output);
    Ok(())
}

fn evaluate(
    program: Vec<Instruction>,
    verbose: bool,
) -> Result<Expression, anyhow::Error> {
    let mut machine = Machine::create(program, verbose);
    let answer = machine.evaluate_until_finished(1);
    Ok(answer)
}
