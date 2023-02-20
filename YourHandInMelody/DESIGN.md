C-like syntax:

```
Program := Item*

Item := FuncType Name ParamList ( ':' Type )? Block

FuncType := 'sound' | 'oscillator'

ParamList := '(' ( Param ( ',' Param )* ','? )? ')'
Param := Name ':' Type

Block := '{' Statement* '}'

Statement := 'let' Name ( ':' Type )? = Expr LineEnd
           | 'set!' Name T_Operator Expr LineEnd
           | 'for' Name 'in' Expr Block LineEnd
           | 'return' Expr? LineEnd
           | CallExpr LineEnd

LineEnd := ';' | '\n'

Expr := BinExpr
BinExpr := UnExpr ( T_Operator UnExpr )*
UnExpr := ('+' | '-')? PrimExpr
PrimExpr := CallExpr
          | LiteralExpr
          | Name
          | '(' Expr ')'
CallExpr := Name '(' Expr ( ',' Expr )* ','? )? ')'
LiteralExpr := T_Number Name?

Name := T_Ident
Type := T_Ident

T_Ident := /[a-zA-Z_][a-zA-Z_0-9!?]*/
T_Number := /[0-9]+(\.[0-9]*)?|[0-9]*\.[0-9]+/
T_Operator := /[\+-\/*^<>|&]*/
```
