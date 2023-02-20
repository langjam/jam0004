use colored::Colorize;
use std::collections::VecDeque;
use std::error::Error;
use std::fmt::{Arguments, Display, Formatter};
use std::io::{Bytes, Read};
use std::iter::Peekable;
use std::ops::AddAssign;
use std::{fmt, io, mem};
use unicode_reader::CodePoints;

pub struct Lexer<I>
where
    I: Iterator<Item = io::Result<u8>>,
{
    buf: VecDeque<Token>,
    input: Peekable<CodePoints<I>>,
    src: SrcLoc,
}

impl<I> Lexer<I>
where
    I: Iterator<Item = io::Result<u8>>,
{
    pub fn new_from_iter(i: I) -> Self {
        Self {
            buf: VecDeque::new(),
            src: SrcLoc::zero(),
            input: CodePoints::from(i).peekable(),
        }
    }
}

impl<R> Lexer<Bytes<R>>
where
    R: Read,
{
    pub fn new_from_reader(r: R) -> Self {
        Self::new_from_iter(r.bytes())
    }
}

#[derive(Ord, PartialOrd, Eq, PartialEq, Clone, Debug)]
pub struct Token {
    pub start: SrcLoc,
    ty: TokenType,
    pub value: String,
}

impl Token {
    pub fn start(&self) -> SrcLoc {
        self.start.clone()
    }

    pub fn end(&self) -> SrcLoc {
        let mut end = self.start();
        end += &self.value;
        end
    }

    pub fn span(&self) -> Span {
        Span {
            start: self.start(),
            end: self.end(),
        }
    }
}

#[derive(Copy, Clone, Debug, Ord, PartialOrd, Eq, PartialEq)]
enum TokenType {
    Unknown,

    Whitespace,
    Comment,
    LineBreak,

    ParOpen,
    ParClose,
    BrOpen,
    BrClose,
    SqOpen,
    SqClose,
    Comma,
    Colon,
    Semicolon,
    Eq,

    Ident,
    Number,
    Operator,

    KwFor,
    KwDo,
    KwLet,
    KwIn,
    KwAt,
    KwReturn,
    KwSet,
}

use TokenType::*;

impl TokenType {
    fn can_ignore(self) -> bool {
        matches!(self, Whitespace | Comment | LineBreak)
    }
}

impl Display for TokenType {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        let s = match self {
            Unknown => "unknown",
            Whitespace => "whitespace",
            Comment => "comment",
            LineBreak => "line break",
            ParOpen => "'('",
            ParClose => "')'",
            BrOpen => "'{'",
            BrClose => "'}'",
            SqOpen => "'['",
            SqClose => "']'",
            Comma => "','",
            Colon => "':'",
            Semicolon => "';'",
            Eq => "'='",
            Ident => "identifier",
            Number => "number",
            Operator => "operator",
            KwFor => "'for'",
            KwLet => "'let'",
            KwIn => "'in'",
            KwAt => "'at'",
            KwReturn => "'return'",
            KwSet => "'set!'",
            KwDo => "'do'",
        };
        write!(f, "{}", s)
    }
}

#[derive(Clone, Ord, PartialOrd, Eq, PartialEq, Debug)]
pub struct Span {
    pub start: SrcLoc,
    pub end: SrcLoc,
}

impl<'a> From<&'a Expr> for Span {
    fn from(value: &'a Expr) -> Self {
        value.span()
    }
}

impl Display for Span {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(f, "{} to {}", self.start, self.end)
    }
}

impl Span {
    pub fn new(start: SrcLoc, end: SrcLoc) -> Self {
        Self { start, end }
    }

    pub fn err(self, msg: impl Into<String>) -> SourcedError {
        SourcedError {
            span: self,
            msg: msg.into(),
            notes: Vec::new(),
        }
    }

    pub fn but_end(&self, other: Span) -> Span {
        Self::new(self.start.clone(), other.end.clone())
    }
}

#[derive(Clone, Ord, PartialOrd, Eq, PartialEq, Debug)]
pub struct SrcLoc {
    // in code points
    pub line: u32,
    pub column: u32,
    // in bytes
    pub pos: usize,
}

impl Display for SrcLoc {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(f, "{}:{}", self.line, self.column)
    }
}

impl SrcLoc {
    pub fn zero() -> Self {
        Self {
            line: 1,
            column: 1,
            pos: 0,
        }
    }

    pub fn span(&self, s: impl AsRef<str>) -> Span {
        let mut span = Span::new(self.clone(), self.clone());
        span.end += s;
        span
    }
}

impl<S: AsRef<str>> AddAssign<S> for SrcLoc {
    fn add_assign(&mut self, rhs: S) {
        for c in rhs.as_ref().chars() {
            self.pos += c.len_utf8();
            if c == '\n' {
                self.column = 1;
                self.line += 1;
            } else {
                self.column += 1;
            }
        }
    }
}

trait TokenPred: Display {
    fn check(&self, tok: &Token) -> bool;
}

impl<T> TokenPred for &T
where
    T: TokenPred,
{
    fn check(&self, tok: &Token) -> bool {
        (*self).check(tok)
    }
}

impl TokenPred for TokenType {
    fn check(&self, tok: &Token) -> bool {
        tok.ty == *self
    }
}

impl<const N: usize, T> Display for AnyPred<[T; N]>
where
    T: Display,
{
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        for i in 0..(N - 1) {
            write!(f, "{}, ", self.0[i])?;
        }
        write!(f, "or {}", self.0[N - 1])
    }
}

struct AnyPred<T>(T);
impl<const N: usize, T> TokenPred for AnyPred<[T; N]>
where
    T: TokenPred,
{
    fn check(&self, tok: &Token) -> bool {
        for p in &self.0 {
            if p.check(tok) {
                return true;
            }
        }
        return false;
    }
}

impl<I> Lexer<I>
where
    I: Iterator<Item = io::Result<u8>>,
{
    fn pos(&self) -> SrcLoc {
        self.buf
            .front()
            .map(|it| &it.start)
            .unwrap_or(&self.src)
            .clone()
    }

    fn unget(&mut self, tok: Token) {
        self.buf.push_front(tok);
    }

    fn peek<'a, P>(&'a mut self, p: P) -> io::Result<Option<TokenType>>
    where
        P: for<'b> Fn(&'b Token) -> bool,
    {
        for i in 0..self.buf.len() {
            let tok = &self.buf[i];
            if p(tok) {
                return Ok(Some(tok.ty));
            }
            if !tok.ty.can_ignore() {
                return Ok(None);
            }
        }
        while let Some(next_tok) = self.parse_next()? {
            self.buf.push_back(next_tok);
            let tok = self.buf.back().unwrap();
            if p(tok) {
                return Ok(Some(tok.ty));
            }
            if !tok.ty.can_ignore() {
                return Ok(None);
            }
        }
        Ok(None)
    }

    fn get<P>(&mut self, p: P) -> io::Result<Option<Token>>
    where
        P: Fn(&Token) -> bool,
    {
        for i in 0..self.buf.len() {
            let tok = &self.buf[i];
            if p(tok) {
                let _ = self.buf.drain(0..i);
                return Ok(self.buf.pop_front());
            }
            if !tok.ty.can_ignore() {
                return Ok(None);
            }
        }
        while let Some(next_tok) = self.parse_next()? {
            if p(&next_tok) {
                self.buf.clear();
                return Ok(Some(next_tok));
            }
            let ty = next_tok.ty;
            self.buf.push_back(next_tok);
            if !ty.can_ignore() {
                return Ok(None);
            }
        }
        Ok(None)
    }

    fn expect<P>(&mut self, p: P, args: Arguments) -> io::Result<Result<Token, SourcedError>>
    where
        P: Fn(&Token) -> bool,
    {
        self.get(p)
            .map(|it| it.ok_or_else(|| self.pos().span("a").err(format!("{}", args))))
    }

    fn maybe_tok(&mut self, p: impl TokenPred) -> io::Result<Option<Token>> {
        self.get(|tok| p.check(tok))
    }

    fn maybe_peek(&mut self, p: impl TokenPred) -> io::Result<Option<TokenType>> {
        self.peek(|tok| p.check(tok))
    }

    fn expect_tok<P>(&mut self, t: P) -> io::Result<Result<Token, SourcedError>>
    where
        P: TokenPred,
    {
        self.expect(|tok| t.check(tok), format_args!("expected {}", t))
    }

    fn token(&mut self, ty: TokenType, value: impl Into<String>) -> Token {
        let value = value.into();
        let start = self.src.clone();
        self.src += &value;
        Token { start, ty, value }
    }

    fn parse_next(&mut self) -> io::Result<Option<Token>> {
        Ok(Some(match self.input.next().transpose()? {
            None => return Ok(None),
            Some(c) => {
                macro_rules! collect_token {
                    ($ty:expr, $(|)? $( $pattern:pat_param )|+ $( if $guard: expr )? $(,)?) => {
                            {
                                let tok = [c]
                                    .into_iter()
                                    .chain(std::iter::from_fn(|| {
                                        self.input
                                            .next_if(
                                                |it| matches!(it, $( $pattern )|+ $( if $guard )?),
                                            )
                                            .map(|it| it.unwrap())
                                    }))
                                    .collect::<String>();
                                self.token($ty, tok)
                            }
                    };
                }
                match c {
                    '\n' => self.token(LineBreak, '\n'),
                    _ if c.is_whitespace() => {
                        collect_token!(Whitespace, Ok(c) if c.is_whitespace() && *c != '\n')
                    }
                    '(' | ')' | '{' | '}' | '[' | ']' | ',' | ':' | ';' => self.token(
                        match c {
                            '(' => ParOpen,
                            ')' => ParClose,
                            '{' => BrOpen,
                            '}' => BrClose,
                            '[' => SqOpen,
                            ']' => SqClose,
                            ',' => Comma,
                            ':' => Colon,
                            ';' => Semicolon,
                            _ => unreachable!(),
                        },
                        c,
                    ),
                    'a'..='z' | 'A'..='Z' | '_' => {
                        let mut tok = collect_token!(
                            Ident,
                            Ok('a'..='z' | 'A'..='Z' | '_' | '0'..='9' | '|' | '?' | '!')
                        );
                        let ty = match tok.value.as_str() {
                            "for" => KwFor,
                            "do" => KwDo,
                            "let" => KwLet,
                            "in" => KwIn,
                            "at" => KwAt,
                            "return" => KwReturn,
                            "set!" => KwSet,
                            _ => Ident,
                        };
                        tok.ty = ty;
                        tok
                    }
                    '0'..='9' | '.' => {
                        collect_token!(Number, Ok('0'..='9' | '.'))
                    }
                    '/' if matches!(self.input.peek(), Some(Ok('/'))) => {
                        collect_token!(Comment, Ok(c) if *c != '\n')
                    }
                    '/' if matches!(self.input.peek(), Some(Ok('*'))) => {
                        let mut s = String::new();
                        let mut depth = 1;
                        enum State {
                            SawStar,
                            SawSlash,
                            SawNothing,
                        }
                        use State::*;
                        let mut state = SawNothing;
                        while let Some(c) = self.input.next() {
                            let c = c?;
                            s.push(c);
                            state = match (state, c) {
                                (SawStar, '/') => {
                                    depth -= 1;
                                    if depth == 0 {
                                        break;
                                    }
                                    SawNothing
                                }
                                (SawSlash, '*') => {
                                    depth += 1;
                                    SawNothing
                                }
                                (_, '*') => SawStar,
                                (_, '/') => SawSlash,
                                (_, _) => SawNothing,
                            };
                        }
                        self.token(Comment, s)
                    }
                    '+' | '-' | '%' | '/' | '*' | '^' | '<' | '>' | '=' => {
                        let mut tok = collect_token!(
                            Operator,
                            Ok('+' | '-' | '%' | '/' | '*' | '^' | '<' | '>' | '=')
                        );
                        let ty = match tok.value.as_str() {
                            "=" => Eq,
                            _ => Operator,
                        };
                        tok.ty = ty;
                        tok
                    }
                    _ => self.token(Unknown, c),
                }
            }
        }))
    }
}

#[derive(Debug)]
pub struct Program {
    pub items: Vec<Item>,
}

#[derive(Debug)]
pub enum Item {
    Func {
        ty: Token,
        name: Token,
        params: Vec<Param>,
        ret_ty: Option<Token>,
        body: Block,
    },
}

#[derive(Debug)]
pub struct Param {
    pub name: Token,
    pub ty: Token,
}

#[derive(Debug)]
pub struct Block {
    pub t_delims: (Token, Token),
    pub stmts: Vec<Stmt>,
}

#[derive(Debug)]
pub enum Stmt {
    Let {
        t_let: Token,
        name: Token,
        ty: Option<Token>,
        val: Expr,
    },
    Set {
        t_set: Token,
        name: Token,
        val: Expr,
    },
    For {
        t_for: Token,
        t_in: Token,
        name: Token,
        hint: Option<Token>,
        iter: Expr,
        block: Block,
    },
    Do {
        t_do: Token,
        name: Token,
        init: Expr,
        cond: Expr,
        step: Expr,
        block: Block,
    },
    Return {
        t_return: Token,
        value: Option<Expr>,
    },
    Call(CallExpr),
}

impl Stmt {
    pub fn span(&self) -> Span {
        match self {
            Stmt::Let { t_let, val, .. } => t_let.span().but_end(val.span()),
            Stmt::Set { t_set, .. } => t_set.span(),
            Stmt::For { t_for, .. } => t_for.span(),
            Stmt::Do { t_do, .. } => t_do.span(),
            Stmt::Return { t_return, .. } => t_return.span(),
            Stmt::Call(ce) => ce.callee.span().but_end(ce.t_pars.1.span()),
        }
    }
}

#[derive(Debug)]
pub enum Expr {
    BinExpr {
        args: Vec<Expr>,
        ops: Vec<Token>,
    },
    UnExpr {
        op: Token,
        arg: Box<Expr>,
    },
    Literal {
        value: Token,
        units: Option<Token>,
    },
    Variable {
        name: Token,
    },
    ParExpr {
        t_pars: (Token, Token),
        expr: Box<Expr>,
    },
    Call {
        ce: CallExpr,
        at: Option<Box<Self>>,
    },
    Array {
        t_delims: (Token, Token),
        children: Vec<Self>,
    },
}

impl Expr {
    pub fn span(&self) -> Span {
        match self {
            Expr::BinExpr { args, .. } => args[0].span().but_end(args[args.len() - 1].span()),
            Expr::UnExpr { op, arg } => op.span().but_end(arg.span()),
            Expr::Literal { value, units } => {
                let mut span = value.span();
                if let Some(u) = units {
                    span = span.but_end(u.span());
                }
                span
            }
            Expr::Variable { name } => name.span(),
            Expr::ParExpr { t_pars, .. } => t_pars.0.span().but_end(t_pars.1.span()),
            Expr::Call { ce, at, .. } => ce.span(at.as_ref().map(|it| &**it)),
            Expr::Array { t_delims, .. } => t_delims.0.span().but_end(t_delims.1.span()),
        }
    }
}

#[derive(Debug)]
pub struct CallExpr {
    pub callee: Token,
    pub t_pars: (Token, Token),
    pub args: Vec<Expr>,
}

impl CallExpr {
    pub fn span(&self, at: Option<&Expr>) -> Span {
        self.callee.span().but_end(match at {
            None => self.t_pars.1.span(),
            Some(e) => e.span(),
        })
    }
}

#[derive(Debug)]
pub struct SourcedError {
    pub span: Span,
    pub msg: String,
    pub notes: Vec<Note>,
}

#[derive(Debug)]
pub struct Note {
    pub kind: NoteKind,
    pub msg: String,
}

#[derive(Debug, Copy, Clone)]
pub enum NoteKind {
    Note,
    Hint,
}

impl Display for NoteKind {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{}",
            match self {
                NoteKind::Note => "note".blue().bold(),
                NoteKind::Hint => "hint".green().bold(),
            }
        )
    }
}

impl Display for SourcedError {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(f, "{}: {}", self.span, self.msg)?;
        for note in &self.notes {
            write!(f, "\n  {}: {}", note.kind, note.msg)?;
        }
        Ok(())
    }
}

impl SourcedError {
    pub fn note_mut(&mut self, kind: NoteKind, msg: impl Into<String>) {
        self.notes.push(Note {
            kind,
            msg: msg.into(),
        });
    }

    pub fn note(mut self, kind: NoteKind, note: impl Into<String>) -> Self {
        self.note_mut(kind, note);
        self
    }
}

impl Error for SourcedError {}

pub struct Parser<I>
where
    I: Iterator<Item = io::Result<u8>>,
{
    lexer: Lexer<I>,
    errors: Vec<SourcedError>,
}

#[derive(Copy, Clone, Ord, PartialOrd, Eq, PartialEq)]
enum Prec {
    Expr,
    BinaryOps,
    UnaryOps,
    Primitives,
}

impl<I> Parser<I>
where
    I: Iterator<Item = io::Result<u8>>,
{
    pub fn new(lexer: Lexer<I>) -> Self {
        Self {
            lexer,
            errors: Vec::new(),
        }
    }

    fn parse_delimited<R>(
        &mut self,
        start: impl TokenPred,
        mut repeat: impl FnMut(&mut Self) -> anyhow::Result<R>,
        delim: impl TokenPred,
        end: impl TokenPred,
    ) -> anyhow::Result<(Token, Vec<R>, Token)> {
        let s = self.lexer.expect_tok(start)??;
        let mut rs = Vec::new();
        let e = loop {
            if let Some(e) = self.lexer.maybe_tok(&end)? {
                break e;
            }
            rs.push(repeat(self)?);
            if self.lexer.maybe_tok(&delim)?.is_none() {
                break self.lexer.expect_tok(&end)??;
            }
        };
        Ok((s, rs, e))
    }

    fn parse_params(&mut self) -> anyhow::Result<Vec<Param>> {
        let (_, params, _) = self.parse_delimited(
            ParOpen,
            |s| {
                Ok(Param {
                    name: s.lexer.expect_tok(Ident)??,
                    ty: {
                        s.lexer.expect_tok(Colon)??;
                        s.lexer.expect_tok(Ident)??
                    },
                })
            },
            Comma,
            ParClose,
        )?;
        Ok(params)
    }

    fn parse_call_expr(&mut self, callee: Token) -> anyhow::Result<CallExpr> {
        let (open, args, close) =
            self.parse_delimited(ParOpen, |s| s.parse_expr(Prec::Expr), Comma, ParClose)?;
        Ok(CallExpr {
            callee,
            args,
            t_pars: (open, close),
        })
    }

    fn parse_expr(&mut self, prec: Prec) -> anyhow::Result<Expr> {
        use self::{Expr::*, Prec::*};

        if prec <= BinaryOps {
            let lhs = self.parse_expr(UnaryOps)?;
            return if let Some(mut op) = self.lexer.maybe_tok(Operator)? {
                let mut args = vec![lhs];
                let mut ops = Vec::new();
                loop {
                    ops.push(op);
                    args.push(self.parse_expr(UnaryOps)?);
                    match self.lexer.maybe_tok(Operator)? {
                        Some(o) => {
                            op = o;
                        }
                        None => {
                            break;
                        }
                    }
                }
                Ok(BinExpr { args, ops })
            } else {
                Ok(lhs)
            };
        }

        if prec <= UnaryOps {
            if let Some(op) = self.lexer.maybe_tok(Operator)? {
                return Ok(UnExpr {
                    op,
                    arg: Box::new(self.parse_expr(Expr)?),
                });
            }
        }

        if prec <= Primitives {
            let tok = self
                .lexer
                .expect_tok(AnyPred([Ident, Number, ParOpen, SqOpen]))??;
            return Ok(match tok.ty {
                Ident => {
                    if self.lexer.maybe_peek(ParOpen)?.is_some() {
                        Call {
                            ce: self.parse_call_expr(tok)?,
                            at: if self.lexer.maybe_tok(KwAt)?.is_some() {
                                Some(Box::new(self.parse_expr(Expr)?))
                            } else {
                                None
                            },
                        }
                    } else {
                        Variable { name: tok }
                    }
                }
                Number => Literal {
                    value: tok,
                    units: {
                        if self.lexer.maybe_peek(LineBreak)?.is_none() {
                            self.lexer.maybe_tok(Ident)?
                        } else {
                            None
                        }
                    },
                },
                ParOpen => ParExpr {
                    expr: Box::new(self.parse_expr(Expr)?),
                    t_pars: (tok, self.lexer.expect_tok(ParClose)??),
                },
                SqOpen => {
                    self.lexer.unget(tok);
                    let (start, children, end) =
                        self.parse_delimited(SqOpen, |s| s.parse_expr(Expr), Comma, SqClose)?;
                    Array {
                        children,
                        t_delims: (start, end),
                    }
                }
                _ => unreachable!(),
            });
        }

        unreachable!()
    }

    fn parse_stmt(&mut self) -> anyhow::Result<Stmt> {
        let tok = self
            .lexer
            .expect_tok(AnyPred([KwLet, KwSet, KwDo, KwFor, KwReturn, Ident]))??;
        use Stmt::*;
        Ok(match tok.ty {
            KwLet => Let {
                t_let: tok,
                name: self.lexer.expect_tok(Ident)??,
                ty: self.parse_type_hint()?,
                val: {
                    self.lexer.expect_tok(Eq)??;
                    self.parse_expr(Prec::Expr)?
                },
            },
            KwSet => Set {
                t_set: tok,
                name: self.lexer.expect_tok(Ident)??,
                val: {
                    self.lexer.expect_tok(Eq)??;
                    self.parse_expr(Prec::Expr)?
                },
            },
            KwFor => For {
                t_for: tok,
                name: self.lexer.expect_tok(Ident)??,
                hint: self.parse_type_hint()?,
                t_in: self.lexer.expect_tok(KwIn)??,
                iter: self.parse_expr(Prec::Expr)?,
                block: self.parse_block()?,
            },
            KwDo => Do {
                t_do: tok,
                name: self.lexer.expect_tok(Ident)??,
                init: {
                    self.lexer.expect_tok(Eq)??;
                    self.parse_expr(Prec::Expr)?
                },
                cond: {
                    self.lexer.expect_tok(Semicolon)??;
                    self.parse_expr(Prec::Expr)?
                },
                step: {
                    self.lexer.expect_tok(Semicolon)??;
                    self.parse_expr(Prec::Expr)?
                },
                block: self.parse_block()?,
            },
            KwReturn => Return {
                t_return: tok,
                value: {
                    if self
                        .lexer
                        .maybe_peek(AnyPred([Semicolon, LineBreak]))?
                        .is_none()
                    {
                        Some(self.parse_expr(Prec::Expr)?)
                    } else {
                        None
                    }
                },
            },
            Ident => Call(self.parse_call_expr(tok)?),
            _ => unreachable!(),
        })
    }

    fn parse_type_hint(&mut self) -> anyhow::Result<Option<Token>> {
        Ok(match self.lexer.maybe_tok(Colon)? {
            None => None,
            Some(_) => Some(self.lexer.expect_tok(Ident)??),
        })
    }

    fn parse_block(&mut self) -> anyhow::Result<Block> {
        let open = self.lexer.expect_tok(BrOpen)??;
        let mut stmts = Vec::new();
        let close = if let Some(c) = self.lexer.maybe_tok(BrClose)? {
            c
        } else {
            loop {
                stmts.push(self.parse_stmt()?);
                if let Some(c) = self.lexer.maybe_tok(BrClose)? {
                    break c;
                } else {
                    self.lexer.expect_tok(AnyPred([LineBreak, Semicolon]))??;
                    if let Some(c) = self.lexer.maybe_tok(BrClose)? {
                        break c;
                    }
                }
            }
        };
        Ok(Block {
            t_delims: (open, close),
            stmts,
        })
    }

    fn parse_item(&mut self) -> anyhow::Result<Item> {
        let fn_ty = self.lexer.expect_tok(Ident)??;
        let name = self.lexer.expect_tok(Ident)??;
        let params = self.parse_params()?;
        let ret_ty = self.parse_type_hint()?;
        let body = self.parse_block()?;
        Ok(Item::Func {
            ty: fn_ty,
            name,
            ret_ty,
            params,
            body,
        })
    }

    pub fn parse_program(&mut self) -> anyhow::Result<(Program, Vec<SourcedError>)> {
        let mut items = Vec::new();
        while self.lexer.peek(|it| !it.ty.can_ignore())?.is_some() {
            match self.parse_item() {
                Ok(item) => {
                    items.push(item);
                }
                Err(err) => {
                    let parse_error: SourcedError = err.downcast()?;
                    self.errors.push(parse_error);
                    // try to recover
                    while let Some(tok) = self.lexer.get(|it| !it.ty.can_ignore())? {
                        if tok.start.column == 0 {
                            break;
                        }
                    }
                }
            }
        }
        let errors = mem::replace(&mut self.errors, Vec::new());
        Ok((Program { items }, errors))
    }
}

#[cfg(test)]
mod tests {
    use crate::parser::{Lexer, Parser, TokenType::*};

    #[test]
    fn test_lex() {
        let mut lex = Lexer::new_from_reader(std::io::Cursor::new("foo + bar + baz\n"));
        let toks = std::iter::from_fn(|| lex.get(|_| true).unwrap()).collect::<Vec<_>>();
        println!("{:?}", toks);
        assert_eq!(
            vec![
                Ident, Whitespace, Operator, Whitespace, Ident, Whitespace, Operator, Whitespace,
                Ident, LineBreak
            ],
            toks.into_iter().map(|it| it.ty).collect::<Vec<_>>()
        );
    }

    #[test]
    fn test_parse() {
        let mut parser = Parser::new(Lexer::new_from_reader(std::io::Cursor::new(
            "\
        foo bar() {
          hi()
          return cool()
        }\
        ",
        )));
        let (program, errors) = parser.parse_program().unwrap();
        assert!(errors.is_empty(), "{:#?}", errors);
        println!("{:#?}", program);
    }
}
