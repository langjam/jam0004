{
open Parser
}

let ident_start = ['A'-'Z'] | ['a'-'z'] | ['_']
let ident = ident_start | ['0'-'9']

rule token = parse
| 'A'  { NOTE(A) }
| "A#" { NOTE(ASharp) }
| "Bb" { NOTE(BFlat) }
| "B"  { NOTE(B) }
| "C"  { NOTE(C) }
| "C#" { NOTE(CSharp) }
| "Db" { NOTE(DFlat) }
| "D"  { NOTE(D) }
| "D#" { NOTE(DSharp) }
| "Eb" { NOTE(EFlat) }
| "E"  { NOTE(E) }
| "F"  { NOTE(F) }
| "F#" { NOTE(FSharp) }
| "Gb" { NOTE(GFlat) }
| "G"  { NOTE(G) }
| "G#" { NOTE(GSharp) }
| "Ab" { NOTE(AFlat) }
| [' ' '\t' '\n']       { token lexbuf }
| ['0'-'9']+ as literal { INT(int_of_string literal) }
| "let"                 { LET }
| "const"               { CONST }
| "in"                  { IN }
| (ident_start ident*) as str { IDENT(str) }
| "="                   { EQUALS }
| "\\"                  { LAMBDA }
| "->"                  { ARROW }
| "("                   { LPAREN }
| ")"                   { RPAREN }
| "["                   { LBRACKET }
| "]"                   { RBRACKET }
| "|"                   { PIPE }
| ","                   { COMMA }
| "/"                   { SLASH }
| ":"                   { COLON }
| eof  { EOF }

