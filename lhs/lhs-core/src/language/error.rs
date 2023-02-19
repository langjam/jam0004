use std::num::ParseIntError;
use thiserror::Error;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Debug, Error)]
pub enum Error {
    #[error("Invalid character: `{0}`")]
    Token(char),
    #[error(transparent)]
    Int(#[from] ParseIntError),
}
