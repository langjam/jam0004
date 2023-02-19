//
// Part of Numpad
// Copyright (c) 2023 Remy Pierre Bushnell Clarke & Sander in 't Veld
// License: MIT
//

pub type Integral = usize;

pub type Float = f64;

#[derive(Debug, Clone, Copy)]
pub enum Unary {
    Fetch,
    Signum,
    Neg,
    Recip,

    Ceiling,
    Floor,
    Print,
}

#[derive(Debug, Clone, Copy)]
pub enum Binary {
    Plus,
    Mult,
    Assign,
    CallWith,

    Abort,
}

#[derive(Debug, Clone)]
pub enum Expression {
    Undefined,
    Number(Float),
    List(Vec<Expression>),
    Sequence(std::collections::VecDeque<Expression>),
    Unary {
        operator: Unary,
        operand: Box<Expression>,
    },
    Binary {
        operator: Binary,
        left: Box<Expression>,
        right: Box<Expression>,
    },
    PointerIntoList {
        address: usize,
        offset: usize,
    },
    Stub,
}

impl Default for Expression {
    fn default() -> Expression {
        Expression::Undefined
    }
}

impl std::fmt::Display for Expression {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Expression::Undefined => write!(f, "undefined"),
            Expression::Number(number) => write!(f, "({})", number),
            Expression::List(elements) => {
                write!(f, "list [")?;
                for element in elements {
                    write!(f, "{element}, ")?;
                }
                write!(f, "]")
            }
            Expression::PointerIntoList { address, offset } => {
                write!(f, "pointer to list {address}:{offset}")
            }
            Expression::Sequence(elements) => {
                write!(f, "sequence [")?;
                for element in elements {
                    write!(f, "{element}, ")?;
                }
                write!(f, "]")
            }
            Expression::Unary { operator, operand } => {
                write!(f, "{operator:?}({operand})")
            }
            Expression::Binary {
                operator,
                left,
                right,
            } => write!(f, "{operator:?}({left} {right})"),
            Expression::Stub => write!(f, "<?>"),
        }
    }
}

#[derive(Debug)]
pub struct Instruction {
    pub label: Integral,
    pub expression: Expression,
}
