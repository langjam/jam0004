type duration = N16 | N8 | N4 | N2 | N1

type note =
  | A
  | ASharp // same
  | BFlat // thing
  | B
  | C
  | CSharp // same
  | DFlat // thing
  | D
  | DSharp // same
  | EFlat // thing
  | E
  | F
  | FSharp // same
  | GFlat // thing
  | G
  | GSharp // same
  | AFlat // thing

type rec expr =
  // x
  | Var(string, Unique.t)
  // \x. e
  | Lambda(string, expr)
  // let x in e
  | Let(string, Unique.t, expr)
  // e1 = e2
  | Unify(expr, expr)
  // e1 e2
  | App(expr, expr)
  // e1 | e2
  | Choice(expr, expr)
  // e1 : e2
  | Cons(expr, expr)
  // []
  | EmptyList
  // list e
  | Sequentialize(expr)
  // fail
  | Fail
  // C
  | Note(note)
  // n8 e
  | Duration(duration, expr)
