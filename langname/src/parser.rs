//! The worlds dumbest parser for datalog!
//!
//! I really should have just used chompsky or something, but it's working well
//! enough for now.

use miette::Diagnostic;
use thiserror::Error;

type Result<T> = std::result::Result<T, SyntaxError>;

#[derive(Debug, Diagnostic, Error)]
#[error("{}", reason)]
#[diagnostic(code(parser))]
pub struct SyntaxError {
    reason: String,

    #[source_code]
    input: String,

    #[label]
    span: Option<(usize, usize)>,
}

impl SyntaxError {
    fn new(reason: impl Into<String>) -> Self {
        SyntaxError {
            reason: reason.into(),
            span: None,
            input: String::new(),
        }
    }

    fn with_span<'a>(mut self, input: &'a str, context: &Context<'a>) -> Self {
        // Not a real parser, but we're assuming that input is a slice of
        // context.input. This is, uh, bad. Don't worry about it. It's
        // _technically_ safe though!
        let start_ok = (context.input.as_ptr() as usize) <= (input.as_ptr() as usize);
        let end_ok = (context.input.as_ptr() as usize + context.input.len())
            >= (input.as_ptr() as usize + input.len());

        if start_ok && end_ok {
            let offset = (input.as_ptr() as usize) - (context.input.as_ptr() as usize);
            let len = input.len();
            self.span = Some((offset, len));
            self.input = context.input.to_owned();
        }

        self
    }
}

pub type Program = Vec<Statement>;

#[derive(Debug, Clone, PartialEq)]
pub enum Statement {
    Fact(Fact),
    Rule(Rule),
}

// Things like `parent(xerces, brooke).`
#[derive(Debug, Clone, PartialEq)]
pub struct Fact(Relation, Vec<Constant>);

// ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
#[derive(Debug, Clone, PartialEq)]
pub struct Rule(Atom, Vec<Atom>);

#[derive(Debug, Clone, PartialEq)]
pub struct Atom(Relation, Vec<Term>);

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Term {
    Const(Constant),
    Var(Variable),
}

pub type Relation = usize;
pub type Constant = usize;
pub type Variable = usize;

#[derive(Debug)]
pub struct Context<'a> {
    pub input: &'a str,
    pub names: Vec<&'a str>,
}

impl<'a> Context<'a> {
    pub fn new(input: &'a str) -> Context<'a> {
        Context {
            input,
            names: vec![],
        }
    }
}

fn make_name<'a>(name: &'a str, context: &mut Context<'a>) -> usize {
    if let Some(i) = context.names.iter().position(|n| n == &name) {
        i
    } else {
        let i = context.names.len();
        context.names.push(name);
        i
    }
}

fn make_name_lower<'a>(name: &'a str, context: &mut Context<'a>) -> Result<usize> {
    if name.chars().all(|c| c.is_ascii_lowercase()) {
        Ok(make_name(name, context))
    } else {
        Err(SyntaxError::new("expected an uppercase name").with_span(name, context))
    }
}

fn make_name_upper<'a>(name: &'a str, context: &mut Context<'a>) -> Result<usize> {
    if name.chars().all(|c| c.is_ascii_uppercase()) {
        Ok(make_name(name, context))
    } else {
        Err(SyntaxError::new("expected a lowercase name").with_span(name, context))
    }
}

pub fn parse<'a>(input: &'a str, context: &mut Context<'a>) -> Result<Program> {
    input
        .split(".")
        .filter(|s| !s.trim().is_empty())
        .map(|s| parse_statement(s.trim(), context))
        .collect()
}

fn parse_statement<'a>(input: &'a str, context: &mut Context<'a>) -> Result<Statement> {
    let input = input.trim();
    Ok(if input.contains(":-") {
        Statement::Rule(parse_rule(input, context)?)
    } else {
        Statement::Fact(parse_fact(input, context)?)
    })
}

fn parse_fact<'a>(input: &'a str, context: &mut Context<'a>) -> Result<Fact> {
    let (r, cs) = input
        .split_once("(")
        .ok_or(SyntaxError::new("this fact is missing it's `(`").with_span(input, context))?;

    let relation = make_name_lower(r.trim(), context)?;

    let cs = cs.trim();

    if !cs.ends_with(")") {
        return Err(
            SyntaxError::new("this fact is missing it's closing `)`").with_span(input, context)
        );
    }

    let constants: Result<Vec<_>> = cs[..cs.len() - 1]
        .split(",")
        .map(|c| make_name_lower(c.trim(), context))
        .collect();

    Ok(Fact(relation, constants?))
}

fn parse_rule<'a>(input: &'a str, context: &mut Context<'a>) -> Result<Rule> {
    let (atom, atoms) = input.split_once(":-").unwrap();

    let head = parse_atom(atom.trim(), context)?;

    let mut atoms = atoms.trim();
    let mut buf = vec![];
    while let Some(i) = atoms.find(")") {
        buf.push(parse_atom(&atoms[0..i + 1].trim(), context)?);
        atoms = &atoms[i + 1..].trim();
        if atoms.starts_with(",") {
            atoms = &atoms[1..].trim();
        }
    }

    Ok(Rule(head, buf))
}

fn parse_term<'a>(input: &'a str, context: &mut Context<'a>) -> Result<Term> {
    if input.chars().all(|c| c.is_ascii_lowercase()) {
        Ok(Term::Const(make_name(input, context)))
    } else {
        Ok(Term::Var(make_name_upper(input, context)?))
    }
}

fn parse_atom<'a>(input: &'a str, context: &mut Context<'a>) -> Result<Atom> {
    let (r, terms) = input
        .split_once("(")
        .ok_or(SyntaxError::new("this atom missing it's `(`").with_span(input, context))?;

    let relation = make_name_lower(r.trim(), context)?;

    let terms = terms.trim();

    if !terms.ends_with(")") {
        return Err(SyntaxError::new("this atom is missing it's `)`").with_span(input, context));
    }

    let terms: Result<Vec<_>> = terms[..terms.len() - 1]
        .split(",")
        .map(|t| parse_term(t.trim(), context))
        .collect();

    Ok(Atom(relation, terms?))
}

#[cfg(test)]
mod parser_tests {
    use super::*;

    #[test]
    fn empty() {
        let input = "";
        let mut context = Context::new(input);
        let syntax = parse(input, &mut context).unwrap();
        assert!(syntax.is_empty())
    }

    #[test]
    fn empty2() {
        let input = "     ";
        let mut context = Context::new(input);
        let syntax = parse(input, &mut context).unwrap();
        assert!(syntax.is_empty())
    }

    #[test]
    fn fact() {
        let input = " fact ( a, b, c ) ";
        let mut context = Context::new(input);
        let syntax = parse_fact(input, &mut context).unwrap();
        assert_eq!(syntax, Fact(0, vec![1, 2, 3]))
    }

    #[test]
    fn atom() {
        let input = "ancestor(X, Y)";
        let mut context = Context::new(input);
        let syntax = parse_atom(input, &mut context).unwrap();
        assert_eq!(syntax, Atom(0, vec![Term::Var(1), Term::Var(2)]),)
    }

    #[test]
    fn rule() {
        let input = "ancestor(X, Y) :- parent(X, Y)";
        let mut context = Context::new(input);
        let syntax = parse_rule(input, &mut context).unwrap();
        assert_eq!(
            syntax,
            Rule(
                Atom(0, vec![Term::Var(1), Term::Var(2)]),
                vec![Atom(3, vec![Term::Var(1), Term::Var(2)])]
            ),
            "got {:#?}",
            syntax
        )
    }

    #[test]
    fn rule_compound() {
        //                 0        1  2     3      1  4   0        4  2
        let input = "ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y)";
        let mut context = Context::new(input);
        let syntax = parse_rule(input, &mut context).unwrap();
        assert_eq!(
            syntax,
            Rule(
                Atom(0, vec![Term::Var(1), Term::Var(2)]),
                vec![
                    Atom(3, vec![Term::Var(1), Term::Var(4)]),
                    Atom(0, vec![Term::Var(4), Term::Var(2)]),
                ]
            ),
            "got {:#?}",
            syntax
        )
    }
}
