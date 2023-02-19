/**/

use crate::common::*;

use logos::Logos;

pub fn lex(
    source: &str,
    verbose: bool,
) -> Result<Vec<LabelPass1>, anyhow::Error> {
    let mut lex: logos::Lexer<Token> = Token::lexer(source);
    let mut definition_end = false;
    let mut tree: Vec<LabelPass1> = vec![];
    let mut prev_num = false;
    let mut current_token_tree: Vec<TokenTreePass1> = vec![];
    let mut defer_nest: Vec<Vec<TokenTreePass1>> = vec![];
    while let Some(token) = lex.next() {
        if verbose {
            if token == Token::Error {
                println!("\n{:?}\t| {token:?} ", lex.slice())
            } else {
                print!("\n{:?}\t| {token:?} ", lex.slice().trim())
            }
        }
        let mut operator = |x, y| -> Result<(), anyhow::Error> {
            if definition_end {
                Err(Error::ExpectedSeparator)?;
            };
            current_token_tree.push(if prev_num {
                TokenTreePass1::Binary(x)
            } else {
                TokenTreePass1::Unary(y)
            });
            prev_num = false;
            Ok(())
        };
        match token {
            Token::Star => operator(Binary::Mult, Unary::Fetch)?,
            Token::Plus => operator(Binary::Plus, Unary::Signum)?,
            Token::Minus => operator(Binary::Assign, Unary::Neg)?,
            Token::Slash => operator(Binary::CallWith, Unary::Recip)?,

            Token::OpenExpr => {
                if prev_num || definition_end {
                    Err(Error::ExpectedSeparator)?;
                };
                defer_nest.push(core::mem::take(&mut current_token_tree))
            }
            Token::CloseExpr => {
                if definition_end {
                    Err(Error::ExpectedSeparator)?;
                };
                let last = defer_nest
                    .last_mut()
                    .ok_or_else(|| Error::UnbalancedDelimiter)?;
                last.push(TokenTreePass1::NestExpr(core::mem::take(
                    &mut current_token_tree,
                )));
                core::mem::swap(last, &mut current_token_tree);
                defer_nest.pop().unwrap();
            }
            Token::Separator => {
                definition_end = false;
                prev_num = false;
                current_token_tree.push(TokenTreePass1::Sep)
            }
            Token::Number => {
                if definition_end {
                    tree.push(LabelPass1(core::mem::take(
                        &mut current_token_tree,
                    )))
                };
                definition_end = false;
                prev_num = true;
                let src: String = lex.slice().split_whitespace().collect();
                current_token_tree.push(if src.contains(".") {
                    src.parse().map(TokenTreePass1::Float)?
                } else {
                    src.parse().map(TokenTreePass1::Int)?
                })
            }
            Token::Enter => {
                definition_end = true;
            }
            Token::Error if lex.slice().trim() == "" => {}
            Token::Error if lex.slice().starts_with('(') => {}
            Token::Error => Err(Error::Unstructured)?,
        }
    }
    tree.push(LabelPass1(core::mem::take(&mut current_token_tree)));

    if verbose {
        println!();
        println!();
        for LabelPass1(tokens) in tree.iter() {
            {
                println!("Label : ")
            };
            for i in tokens.iter() {
                println!("\t{i:?}")
            }
        }
    }
    Ok(tree)
}

#[derive(Logos, Debug, PartialEq)]
enum Token {
    // Operators
    #[regex(r"\*[ \t]*")]
    Star,
    #[regex(r"\+[ \t]*")]
    Plus,
    #[regex(r"\-[ \t]*")]
    Minus,
    #[regex(r"/[ \t]*")]
    Slash,

    // Structurals
    #[regex(r"/\.[ \t]*")]
    OpenExpr,
    #[regex(r"\./[ \t]*")]
    CloseExpr,
    #[regex(r"\.\.[ \t]*")]
    Separator,

    // Literals
    #[regex(r"[0-9][0-9 \t]*(\.[0-9 \t]+)?")]
    Number,

    // Display
    #[token("\n")]
    Enter,
    #[error]
    #[regex(r"\(.*\)", logos::skip)]
    Error,
}

#[derive(Debug)]
pub struct LabelPass1(pub Vec<TokenTreePass1>);

#[derive(Debug, Clone)]
pub enum TokenTreePass1 {
    Int(Integral),
    Float(Float),
    NestExpr(Vec<TokenTreePass1>),
    Unary(Unary),
    Binary(Binary),
    Sep,
}

#[derive(Debug, thiserror::Error)]
enum Error {
    #[error("Unbalanced delimiter")]
    UnbalancedDelimiter,
    #[error("Expected separator")]
    ExpectedSeparator,
    #[error("Unstructured")]
    Unstructured,
}
