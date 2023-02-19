use chumsky::{error::Simple, Span};
use miette::{Diagnostic, NamedSource};
use thiserror::Error;

#[derive(Debug, Diagnostic, Error)]
#[diagnostic()]
#[error("error: {reason}")]
pub struct Error {
    reason: String,

    label: String,

    #[label("{label}")]
    span: Option<(usize, usize)>,

    #[related]
    errors: Vec<Error>,

    #[source_code]
    source_code: NamedSource,
}

impl Error {
    pub fn new(reason: impl Into<String>) -> Error {
        Error {
            reason: reason.into(),
            span: None,
            label: String::new(),
            errors: Vec::new(),
            source_code: NamedSource::new("<unknown input>", ""),
        }
    }

    pub fn with_span(mut self, start: usize, len: usize) -> Self {
        self.span = Some((start, len));
        self
    }

    pub fn with_labeled_span(mut self, start: usize, len: usize, label: impl Into<String>) -> Self {
        self.label = label.into();
        self.with_span(start, len)
    }

    pub fn with_source_code(mut self, source_code: NamedSource) -> Self {
        self.source_code = source_code;
        self
    }
}

impl<E> From<Vec<E>> for Error
where
    E: Into<Error>,
{
    fn from(errors: Vec<E>) -> Self {
        let mut errors = errors;
        if errors.len() == 1 {
            let e = errors.pop().unwrap();
            e.into()
        } else {
            let mut error = errors.pop().unwrap().into();
            error.errors = errors.into_iter().map(Into::into).collect();
            error
        }
    }
}

impl From<Simple<char>> for Error {
    fn from(error: Simple<char>) -> Self {
        Error::new(format!("syntax error")).with_labeled_span(
            error.span().start(),
            error.span().len(),
            format!("{error}"),
        )
    }
}
