use super::{error::Result, Token, TokenStream};
use crate::BASE;
use std::iter::Peekable;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Instruction {
    Count(usize),
    Move(Move),
    Fetch,
    Give,
    Copy,
    Void,
    Increment,
    Decrement,
    To,
    Equal,
    NotEqual,
    Read,
    Brrr,
    Nop,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Move {
    Up,
    Down,
    Left,
    Right,
}

// pub fn parse(token_stream: TokenStream) -> Result<Vec<Instruction>> {
//     parse_internal(token_stream.peekable(), vec![])
// }

pub fn parse(tokens: Vec<Result<Token>>) -> Result<Vec<Instruction>> {
    let token_stream = Box::new(tokens.into_iter()).peekable();
    parse_internal(token_stream, vec![])
}

fn parse_internal(
    mut token_stream: Peekable<TokenStream>,
    mut instructions: Vec<Instruction>,
) -> Result<Vec<Instruction>> {
    if matches!(token_stream.peek(), Some(Ok(Token::Number(_)))) {
        if let Some(Ok(Token::Number(char))) = token_stream.next() {
            let mut numeric_expression = char.to_string();
            while matches!(token_stream.peek(), Some(Ok(Token::Number(_)))) {
                if let Some(Ok(Token::Number(char))) = token_stream.next() {
                    numeric_expression.push(char);
                }
            }

            instructions.push(parse_count(&numeric_expression)?);
            return parse_internal(token_stream, instructions);
        };
    }

    match token_stream.next() {
        Some(Ok(Token::Character(char))) => {
            instructions.push(parse_instruction(char)?);

            parse_internal(token_stream, instructions)
        }
        Some(Err(err)) => Err(err),
        None => Ok(instructions),
        _ => unreachable!("Token::Number is handled above"),
    }
}

/* IDEA
base 5 state machine language, using only the keys on the left hand side of the keyboard
[1-5][q-t][a-g][z-b] and space

1-4: 1-4
5: 0
q: decrement the value under the memory pointer
w: move memory pointer up
e: increment the value under the memory pointer
r: run, runs a builtin, givin the value under the
t: to, go to
a: move memory pointer left
s: move memory pointer down
d: move memory pointer right

f: fetch, push to stack and set to 0
g: give, pop from stack and set cell
z: not equals, stack pointer deref != memory pointer deref
x: equals, stack pointer deref == memory pointer deref
c: copy,
v: void, zero out the current memory cell
b: loop, decrementing the value under the memory pointer until it is zero
Space: Nop, functions as an expression seperator

did i get lazy with the number 5? of course.

*/

fn parse_instruction(char: char) -> Result<Instruction> {
    Ok(match char {
        'q' => Instruction::Decrement,
        'w' => Instruction::Move(Move::Up),
        'e' => Instruction::Increment,
        'r' => Instruction::Read,
        't' => Instruction::To,

        'a' => Instruction::Move(Move::Left),
        's' => Instruction::Move(Move::Down),
        'd' => Instruction::Move(Move::Right),
        'f' => Instruction::Fetch,
        'g' => Instruction::Give,

        'z' => Instruction::Equal,
        'x' => Instruction::NotEqual,
        'c' => Instruction::Copy,
        'v' => Instruction::Void,
        'b' => Instruction::Brrr,

        ' ' => Instruction::Nop,

        _ => unreachable!(),
    })
}

fn parse_count(value: &str) -> Result<Instruction> {
    Ok(Instruction::Count(usize::from_str_radix(value, BASE)?))
}
