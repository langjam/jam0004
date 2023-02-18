
(* The type of tokens. *)

type token = 
  | SLASH
  | RPAREN
  | RBRACKET
  | PIPE
  | NOTE of (Syntax.note)
  | LPAREN
  | LIST
  | LET
  | LBRACKET
  | LAMBDA
  | INT of (int)
  | IN
  | IDENT of (string)
  | FAIL
  | EQUALS
  | DURATION of (Syntax.duration)
  | COMMA
  | COLON
  | ARROW

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val expr: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Syntax.expr)
