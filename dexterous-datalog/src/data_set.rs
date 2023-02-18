use miette::Diagnostic;
use thiserror::Error;

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

#[derive(Default)]
pub struct DataSet {}

impl DataSet {}
