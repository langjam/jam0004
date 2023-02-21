use std::{
    fmt::Display,
    io::{self, Stdout, Write},
};

use super::{Memory, Stack};
use crate::language::{self, Instruction, ParseError, ParseResult};

#[derive(Debug, PartialEq)]
pub struct Machine<W: Write, const M: usize = 8, const S: usize = 8> {
    pub memory: Memory<M>,
    pub stack: Stack<S>,
    pub program_counter: usize,
    pub writer: W,
}

impl<W: Write, const M: usize, const S: usize> Machine<W, M, S> {
    pub fn new(writer: W) -> Self {
        Self {
            memory: Memory::new(),
            stack: Stack::new(),
            program_counter: 0,
            writer,
        }
    }

    pub fn run(&mut self, program: &Program) {
        if program.len() == 1 {
            self.evaluate_expression(program, &program.0[0]);
            return;
        }

        loop {
            self.evaluate_expression(program, &program.0[self.program_counter]);
            if self.program_counter == program.len() - 1 {
                break;
            }

            self.program_counter += 1;
        }
    }
}

impl<const N: usize> Default for Machine<Stdout, N, N> {
    fn default() -> Self {
        Self::new(io::stdout())
    }
}

pub type Expression = Vec<Instruction>;

#[derive(Debug)]
pub struct Program(Vec<Expression>);

impl Program {
    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }

    pub fn len(&self) -> usize {
        self.0.len()
    }
}

impl TryFrom<&str> for Program {
    type Error = ParseError;

    fn try_from(source: &str) -> ParseResult<Self> {
        let token_stream = language::tokenize(source);
        let expression = language::parse(token_stream)?;

        Ok(Self::from(expression))
    }
}

impl TryFrom<&String> for Program {
    type Error = ParseError;

    fn try_from(source: &String) -> Result<Self, Self::Error> {
        let token_stream = language::tokenize(&source);
        let expression = language::parse(token_stream)?;

        Ok(Self::from(expression))
    }
}

impl From<Expression> for Program {
    fn from(expression: Expression) -> Self {
        let inner = expression
            .split(|instruction| matches!(instruction, Instruction::Nop))
            .map(|expression| expression.to_vec())
            .collect::<Vec<Expression>>();

        Self(inner)
    }
}

impl<W: Write, const M: usize, const S: usize> Display for Machine<W, M, S> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let pointers = format!(
            "memory: {}          stack: {}\n",
            self.memory.pointer, self.stack.pointer
        );
        let cells = self.memory.iter().zip(self.stack.iter()).fold(
            "".to_owned(),
            |acc, (mem_row, stack_frame)| {
                let row = mem_row
                    .iter()
                    .fold("".to_owned(), |acc, cell| format!("{acc} {cell}"));

                format!("{acc}|{row} | {stack_frame} |\n")
            },
        );
        let counter = format!("program counter: {}", self.program_counter);

        write!(f, "{pointers}{cells}{counter}")
    }
}
