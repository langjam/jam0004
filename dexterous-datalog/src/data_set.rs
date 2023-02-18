use miette::Diagnostic;
use thiserror::Error;

use crate::parser::{Context, Program};

type Result<T> = std::result::Result<T, DataError>;

#[derive(Debug, Diagnostic, Error)]
#[error("{}", reason)]
#[diagnostic(code(parser))]
pub struct DataError {
    reason: String,

    #[source_code]
    input: String,

    #[label]
    span: Option<(usize, usize)>,
}

pub struct DataSet {}

impl DataSet {
    pub fn new(syntax: &Program, context: &Context) -> Result<DataSet> {
        Ok(DataSet {})
    }
}
