/**/

pub type Integral = usize;

pub type Float = f64;

#[derive(Debug, Clone, Copy)]
pub enum Unary {
    Fetch,
    Signum,
    Neg,
    Recip,
}

#[derive(Debug, Clone, Copy)]
pub enum Binary {
    Plus,
    Mult,
    Assign,
    CallWith,
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

#[derive(Debug)]
pub struct Instruction {
    pub label: Integral,
    pub expression: Expression,
}
