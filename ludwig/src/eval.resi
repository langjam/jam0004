open Syntax

type evalError = 
  | UnboundVariable(string)
  | TryingToCallNonFunction(value)

exception EvalError(evalError)

let eval: (env, expr) => value

let makeEnvironment : unit => env

