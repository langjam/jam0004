use super::error::{self, Error, Result};

// pub fn tokenize(source: &'static str) -> TokenStream {
//     Box::new(
//         source
//             .chars()
//             .filter(|char| *char != '\n' && *char != '\t' && *char != '\r')
//             .map(Token::try_from),
//     )
// }

// pub fn tokenize(source: &'static str) -> Vec<Result<Token>> {
pub fn tokenize(source: &str) -> Vec<Result<Token>> {
    source
        .chars()
        .filter(|char| *char != '\n' && *char != '\t' && *char != '\r')
        .map(Token::try_from)
        .collect()
}

pub type TokenStream = Box<std::vec::IntoIter<Result<Token>>>;

#[derive(Debug, Clone, Copy)]
pub enum Token {
    Number(char),
    Character(char),
}

impl TryFrom<char> for Token {
    type Error = error::Error;

    fn try_from(char: char) -> Result<Self> {
        match char {
            '1' | '2' | '3' | '4' => Ok(Self::Number(char)),
            '5' => Ok(Self::Number('0')),
            'q' | 'w' | 'e' | 'r' | 't' | 'a' | 's' | 'd' | 'f' | 'g' | 'z' | 'x' | 'c' | 'v'
            | 'b' | ' ' => Ok(Self::Character(char)),
            _ => Err(Error::Token(char)),
        }
    }
}
