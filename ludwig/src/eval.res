open Syntax

type env = {variables: Belt.Map.t<unique>}

let eval = (env, expr) =>
  switch expr {
  | Var(x) => todo("aa")
  }
