//! The worlds dumbest parser for datalog!

use chumsky::prelude::*;

pub type Program = Vec<Statement>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Statement {
    Fact(Fact),
    Rule(Rule),
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Repl {
    Program(Program),
    Query(Query),
}

// Things like `parent(padme, luke).`
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Fact(Relation, Vec<Constant>);

// ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Rule(Atom, Vec<Atom>);

// ancestor(X, Y)
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Atom(Relation, Vec<Term>);

// Things like `?- father(X, luke)`
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Query(Vec<Atom>);

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub enum Term {
    Const(Constant),
    Var(Variable),
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct Relation(String);

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct Constant(String);

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub struct Variable(String);

pub fn repl() -> impl Parser<char, Repl, Error = Simple<char>> {
    program()
        .map(|p| Repl::Program(p))
        .or(query().map(|q| Repl::Query(q)))
}

pub fn program() -> impl Parser<char, Program, Error = Simple<char>> {
    statement()
        .separated_by(just('.').padded())
        .allow_trailing()
        .then_ignore(end())
}

// A name looks like a constant if there's at least one letter, and all letters
// are lowercase.
fn is_constant_name(name: &str) -> bool {
    name.chars().any(|c| c.is_ascii_alphabetic())
        && name
            .chars()
            .all(|c| !c.is_ascii_alphabetic() || c.is_ascii_lowercase())
}

fn name() -> impl Parser<char, String, Error = Simple<char>> {
    text::ident().padded()
}

fn term() -> impl Parser<char, Term, Error = Simple<char>> {
    name().map(|n| {
        if is_constant_name(&n) {
            Term::Const(Constant(n))
        } else {
            Term::Var(Variable(n))
        }
    })
}

fn constant() -> impl Parser<char, Constant, Error = Simple<char>> {
    name().validate(|n, span, emit| {
        if !is_constant_name(&n) {
            emit(Simple::custom(
                span,
                format!("expected a constant but found variable `{n}`"),
            ))
        }
        Constant(n)
    })
}

fn relation() -> impl Parser<char, Relation, Error = Simple<char>> {
    name().validate(|n, span, emit| {
        if !is_constant_name(&n) {
            emit(Simple::custom(
                span,
                format!("expected a relation but found variable `{n}`"),
            ))
        }
        Relation(n)
    })
}

fn fact() -> impl Parser<char, Fact, Error = Simple<char>> {
    relation()
        .then(
            constant()
                .separated_by(just(',').padded())
                .allow_trailing()
                .delimited_by(just('(').padded(), just(')').padded()),
        )
        .map(|(relation, terms)| Fact(relation, terms))
}

fn atom() -> impl Parser<char, Atom, Error = Simple<char>> {
    relation()
        .then(
            term()
                .separated_by(just(',').padded())
                .allow_trailing()
                .delimited_by(just('(').padded(), just(')').padded()),
        )
        .map(|(rel, terms)| Atom(rel, terms))
}

fn rule() -> impl Parser<char, Rule, Error = Simple<char>> {
    atom()
        .then(just(":-").padded())
        .then(atom().separated_by(just(',').padded()).allow_trailing())
        .map(|((head, _), body)| Rule(head, body))
}

fn statement() -> impl Parser<char, Statement, Error = Simple<char>> {
    rule()
        .map(|r| Statement::Rule(r))
        .or(fact().map(|f| Statement::Fact(f)))
}

fn query() -> impl Parser<char, Query, Error = Simple<char>> {
    just("?-")
        .padded()
        .then(atom().separated_by(just(',').padded()))
        .map(|(_, atoms)| Query(atoms))
        .then_ignore(end())
}

#[cfg(test)]
mod parser_tests {
    use super::*;

    #[test]
    fn is_constant() {
        assert!(is_constant_name("name"));
        assert!(!is_constant_name("Name"));
        assert!(!is_constant_name("_"));
        assert!(!is_constant_name("_9"));
    }

    #[test]
    fn empty() {
        let input = "";
        let syntax = program().parse(input).unwrap();
        assert!(syntax.is_empty())
    }

    #[test]
    fn parse_fact() {
        let input = " fact ( a, b, c ) ";
        let syntax = fact().parse(input).unwrap();
        assert_eq!(
            syntax,
            Fact(
                Relation("fact".into()),
                vec![
                    Constant("a".into()),
                    Constant("b".into()),
                    Constant("c".into()),
                ]
            )
        )
    }

    #[test]
    fn parse_rule() {
        let input = "ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y)";

        let syntax = rule().parse(input).unwrap();
        assert_eq!(
            syntax,
            Rule(
                Atom(
                    Relation("ancestor".into()),
                    vec![
                        Term::Var(Variable("X".into())),
                        Term::Var(Variable("Y".into()))
                    ]
                ),
                vec![
                    Atom(
                        Relation("parent".into()),
                        vec![
                            Term::Var(Variable("X".into())),
                            Term::Var(Variable("Z".into()))
                        ]
                    ),
                    Atom(
                        Relation("ancestor".into()),
                        vec![
                            Term::Var(Variable("Z".into())),
                            Term::Var(Variable("Y".into()))
                        ]
                    ),
                ]
            ),
        )
    }

    #[test]
    fn parse_query() {
        let input = "ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y)";

        let syntax = rule().parse(input).unwrap();
        assert_eq!(
            syntax,
            Rule(
                Atom(
                    Relation("ancestor".into()),
                    vec![
                        Term::Var(Variable("X".into())),
                        Term::Var(Variable("Y".into()))
                    ]
                ),
                vec![
                    Atom(
                        Relation("parent".into()),
                        vec![
                            Term::Var(Variable("X".into())),
                            Term::Var(Variable("Z".into()))
                        ]
                    ),
                    Atom(
                        Relation("ancestor".into()),
                        vec![
                            Term::Var(Variable("Z".into())),
                            Term::Var(Variable("Y".into()))
                        ]
                    ),
                ]
            ),
        )
    }
}
