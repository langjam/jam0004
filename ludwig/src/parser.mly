%{
open Syntax
%}

%token <string>          IDENT
%token <int>             INT
%token <Syntax.note>     NOTE
%token <Syntax.duration> DURATION
%token LET
%token CONST
%token IN
%token EQUALS "="
%token LAMBDA "\\"
%token ARROW "->"
%token LPAREN "("
%token RPAREN ")"
%token LBRACKET "["
%token RBRACKET "]"
%token PIPE "|"
%token COLON ":"
%token SLASH "/"
%token LIST
%token FAIL
%token COMMA ","
%token EOF



%start <Syntax.expr> main

%type <Syntax.expr> expr
%type <Syntax.expr> expr1
%type <Syntax.expr> expr2
%type <Syntax.expr> expr3
%type <Syntax.expr> expr_leaf


%type <Syntax.expr list> sep_by_trailing(COMMA, expr)
%%

main:
    | expr EOF { $1 }

expr:
    | "\\" IDENT "->" expr { Lambda($2, $4) }
    | expr1 { $1 }

expr1:
    | expr2 "|" expr1 { Choice($1, $3) }
    | expr2 { $1 }

expr2:
    | expr3 ":" expr2 { Cons($1, $3) }
    | expr3 { $1 }

expr3:
    | expr3 expr_leaf { App($1, $2) }
    | expr_leaf { $1 }

expr_leaf:    
    | "(" expr ")"                          { $2 }
    | IDENT                                 { Var($1) }
    | LET IDENT IN expr                     { Let($2, $4) }
    | LET IDENT "=" expr IN expr            { Let($2, Unify(Var($2), $4, $6)) }
    | CONST IDENT IN expr                   { LetConst($2, $4) }
    | expr1 "=" expr IN expr                { Unify($1, $3, $5) }
    | "[" sep_by_trailing(",", expr) "]"    { List.fold_right (fun x rest -> Cons(x, rest)) $2 EmptyList }
    | LIST expr2                            { Sequentialize($2) }
    | FAIL                                  { Fail }
    | NOTE                                  { Note($1) }


// 1/2(A | B) : (C | D)

sep_by_trailing(separator, element):
    | { [] }
    | element { [$1] }
    | element separator sep_by_trailing(separator, element) { $1 :: $3 }
