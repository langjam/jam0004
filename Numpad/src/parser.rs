//
// Part of Numpad
// Copyright (c) 2023 Remy Pierre Bushnell Clarke & Sander in 't Veld
// License: MIT
//

use crate::common::*;
use crate::lexer::LabelPass1;
use crate::lexer::TokenTreePass1;

use itertools::Itertools;
use log::*;

pub fn parse(
    labels: Vec<LabelPass1>,
) -> Result<Vec<Instruction>, anyhow::Error> {
    trace!("");
    labels
        .into_iter()
        .filter(|LabelPass1(tokens)| !tokens.is_empty())
        .map(|LabelPass1(tokens)| parse_instruction(tokens))
        .collect()
}

fn parse_instruction(
    tokens: Vec<TokenTreePass1>,
) -> Result<Instruction, anyhow::Error> {
    let mut tokens = tokens.into_iter().peekable();
    let label = match tokens.next() {
        Some(TokenTreePass1::Int(label)) => label,
        Some(_) => Err(Error::InvalidLabel)?,
        None => unreachable!(),
    };
    let mut intermediates = Vec::new();
    while let Some(separator) = tokens.next() {
        match separator {
            TokenTreePass1::Sep => (),
            other => Err(Error::ExpectedSeparatorInInsruction { got: other })?,
        }
        let tokens = tokens
            .by_ref()
            .peeking_take_while(|token| !is_separator(token));
        let expression = parse_expression(tokens)?;
        intermediates.push(expression);
    }
    let expression = if intermediates.len() > 1 {
        Expression::Sequence(intermediates.into())
    } else {
        intermediates
            .pop()
            .ok_or_else(|| Error::ExpectedExpression)?
    };
    trace!("{}:\t{}", label, expression);
    let instruction = Instruction { label, expression };
    Ok(instruction)
}

fn parse_expression(
    mut tokens: impl std::iter::Iterator<Item = TokenTreePass1>,
) -> Result<Expression, anyhow::Error> {
    let mut expression = None;
    let mut stacked_unaries = Vec::new();
    while let Some(token) = tokens.next() {
        match token {
            TokenTreePass1::Unary(unary) => {
                stacked_unaries.push(unary);
            }
            TokenTreePass1::Binary(binary) => {
                let left = expression
                    .ok_or_else(|| Error::ExpectedExpressionBeforeBinary)?;
                let right = parse_expression(tokens)?;
                expression = Some(Expression::Binary {
                    operator: binary,
                    left: Box::new(left),
                    right: Box::new(right),
                });
                break;
            }
            _ if expression.is_some() => Err(Error::ExpectedOperator)?,
            TokenTreePass1::Int(integral) => {
                expression = Some(Expression::Number(integral as Float));
            }
            TokenTreePass1::Float(float) => {
                expression = Some(Expression::Number(float));
            }
            TokenTreePass1::NestExpr(mut tokens) => {
                if tokens.is_empty() || tokens.iter().any(is_separator) {
                    let elements: Result<Vec<Expression>, anyhow::Error> =
                        tokens
                            .split_mut(is_separator)
                            .filter(|tokens| !tokens.is_empty())
                            .map(|tokens| {
                                let tokens = tokens.to_vec();
                                parse_expression(tokens.into_iter())
                            })
                            .collect();
                    let elements = elements?;
                    expression = Some(Expression::List(elements));
                } else {
                    let inner = parse_expression(tokens.into_iter())?;
                    expression = Some(inner);
                }
            }
            TokenTreePass1::Sep => Err(Error::ExpectedOperator)?,
        }
    }
    let mut expression = expression.ok_or_else(|| Error::ExpectedExpression)?;
    while let Some(unary) = stacked_unaries.pop() {
        expression = Expression::Unary {
            operator: unary,
            operand: Box::new(expression),
        };
    }
    Ok(expression)
}

fn is_separator(token: &TokenTreePass1) -> bool {
    match token {
        TokenTreePass1::Sep => true,
        _ => false,
    }
}

#[derive(Debug, thiserror::Error)]
enum Error {
    #[error("Expected separator, got {got:?}")]
    ExpectedSeparatorInInsruction { got: TokenTreePass1 },
    #[error("Expected expression")]
    ExpectedExpression,
    #[error("Expected expression before binary operator")]
    ExpectedExpressionBeforeBinary,
    #[error("Expected binary operator")]
    ExpectedOperator,
    #[error("Invalid label, must be integral")]
    InvalidLabel,
}
