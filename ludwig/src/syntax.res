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
  // The associated unique is Some iff the variable has been associated with a let binding or lambda at runtime
  | Var(string, option<Unique.t>)
  // \x. e
  | Lambda(string, expr)
  // These can only be created during evaluation. 
  // Lambda expressions always evaluate to closures
  | Closure(env, string, expr)
  // let x in e
  | Let(string, expr)
  // e1 = e2 in e
  | Unify(expr, expr, expr)
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

// This needs to be defined here thanks to closures :/
and env = {
  // Variable values can change independent of their scope. This hashmap captures the
  // values stored inside variable identites.
  // We need to keep a list of scopes since each branch of a choice should get its own (mutable!)
  // scope.
  variableValueScopes: list<Belt.HashMap.t<Unique.t, expr, Unique.Hashable.identity>>,
  
  // This maps variables to their identities, making it possible to look up the value stored in variableValues.
  // Unlike variableValues, this is an *immutable* map which respects lexical scope
  variableIdentities: Belt.Map.String.t<Unique.t>,
}

