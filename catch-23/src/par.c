
// var-declare = "@" ident ":" type

// dont = ":;" expression ")" "{" stmt-list "}"
// against = ";;" expression ")" "{" stmt-list "}"
// until = "::" "(" expression ")" "{" stmt-list "}"
// unless = "??" "(" expression ")" "{" stmt-list "}"

// var-assign = ident "[" expression "]"
// var-ref = "$" ident
// call-args = expression [ "," call-args ]
// function-call = ident "(" call-args ")"
// expression = function-call | var-ref | var-assign

// statement = expression | unless | until | against | dont | var-declare
// type = ("#" | "##" | "#?") [ "*" ] [ "[]" ]
// stmt-list = statement [ stmt-list ]
// function-def = ident ":" type "(" [ arg-list ] ")" "{" stmt-list "}"
// top-level = function-def | statement [ top-level ]
