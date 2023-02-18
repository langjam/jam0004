open Syntax


type evalError = 
  | UnboundVariable(string)
  | TryingToCallNonFunction(expr)

exception EvalError(evalError)

exception Panic(string)

let insertVarValue = (env, unique, expr) => switch env.variableValueScopes {
    | list{} => raise (Panic ("Trying to insert a variable into a non-existant scope"))
    | list{scope, ..._} => {
      Belt.HashMap.set(scope, unique, expr)
    }
  }

let newEvalScope = env => 
  { ...env, variableValueScopes : list{Belt.HashMap.make(~hintSize=10, ~id=module(Unique.Hashable)), ...env.variableValueScopes} }

let rec eval = (env, expr) =>
  switch expr {
  | Var(name, unique) => 
    let unique = switch unique {
      | Some(unique) => unique
      | None => switch Belt.Map.String.get(env.variableIdentities, name) {
          | None => raise(EvalError(UnboundVariable(name)))
          | Some(unique) => unique
      }
    }
    evalVariable(env, name, unique)
  | Lambda(name, body) => {
    Closure(env, name, body)
  }
  | Let(name, rest) =>
    // This creates a new, currently unbound variable with a fresh identity
    let unique = Unique.fresh ()
    
    let updatedEnv = { ...env, variableIdentities : Belt.Map.String.set(env.variableIdentities, name, unique) }

    eval(updatedEnv, rest)
  | Unify(expr1, expr2, rest) =>
    if unify(env, expr1, expr2) {
      eval(env, rest)
    } else {
      Fail
    }
  | App(funExpr, argExpr) => switch eval(env, funExpr) {
    | Lambda(_) => raise (Panic("Unevaluated lamda in application"))
    | Let(_) => raise (Panic ("Unevaluated let in application"))
    | Unify(_) => raise (Panic ("Unevaluated unify in application"))
    | Closure(closureEnv, closureParam, closureBody) => {
      let paramUnique = Unique.fresh ()

      let updatedEnv = { ...closureEnv
                       , variableIdentities : Belt.Map.String.set(closureEnv.variableIdentities, closureParam, paramUnique) 
                       }
      insertVarValue(updatedEnv, paramUnique, argExpr)
      eval(updatedEnv, closureBody)
    }
    | (Var(_) | App(_)) as stuckExpr => App(stuckExpr, argExpr)
    | Choice(leftChoice, rightChoice) => {
      let leftValue = eval(newEvalScope(env), App(leftChoice, argExpr))
      let rightValue = eval(newEvalScope(env), App(rightChoice, argExpr))
      Choice(leftValue, rightValue)
    }
    | (Cons(_) | EmptyList | Sequentialize(_) | Note(_) | Duration(_)) as nonFunctionValue => 
      raise(EvalError(TryingToCallNonFunction(nonFunctionValue)))
    | Fail => Fail
  }
  | Choice(leftChoice, rightChoice) => {
    let leftValue = eval(env, leftChoice)
    let rightValue = eval(env, rightChoice)
    Choice(leftValue, rightValue)
  }
  | Sequentialize(choices) => raise (Panic("TODO"))
  | Fail => Fail
  // All of these are already in whnf
  | Closure(_) | Cons(_) | EmptyList | Note(_) | Duration(_, _) => expr
}

and evalVariable = (env, name, unique) => {
  let rec go = scopes => switch scopes {
    | list{} => {      
      // The variable is free so we return it unevaluated
      Var(name, Some(unique))
    }
    | list{scope, ...rest} => switch Belt.HashMap.get(scope, unique) {
      // There is no binding in this scope, but it might still be bound higher up somewhere
      | None => go(rest)
      | Some(expr) =>
        let whnf = eval(env, expr)
        // Update the variable so that future evaluations don't need to recompute the previous eval step.
        Belt.HashMap.set(scope, unique, whnf)
        whnf
      }
  }
  go(env.variableValueScopes)
}

and unify = (env, expr1, expr2)=> switch eval(env, expr1) {
  | Var(name, None) => raise (Panic("Unbound variable after evaluation: " ++ name))
  | Var(_name, Some(unique)) => {
    // Variable bindings are lazy
    insertVarValue(env, unique, expr2)
    true
  }
  | whnf1 => {
    switch (whnf1, eval(env, expr2)) {
      | (_whnf1, Var(name, None)) => raise (Panic("Unbound variable after evaluation: " ++ name))
      | (whnf1, Var(_name, Some(unique))) => {
        insertVarValue(env, unique, whnf1)
        true
      }
      // Applications should usually be removed by the application,
      // but if the function is irreducible, i.e. a free variable,
      // We may still need to resort to unification
      | (App(funExpr1, argExpr1), App(funExpr2, argExpr2)) => {
        unify(env, funExpr1, funExpr2)
        && unify(env, argExpr1, argExpr2)
      }
      | (Choice(leftChoice, rightChoice), expr) | (expr, Choice(leftChoice, rightChoice)) => {
        // TODO: This doesn't actually bind anything at the moment. 
        // This is almost certainly not what we want
        unify(newEvalScope(env), leftChoice, expr)
        || unify(newEvalScope(env), rightChoice, expr)
      }
      | (Cons(headExpr1, tailExpr1), Cons(headExpr2, tailExpr2)) => {
        unify(env, headExpr1, headExpr2)
        && unify(env, tailExpr1, tailExpr2)
      }
      | (EmptyList, EmptyList) => true
      | (Sequentialize(choices1), Sequentialize(choices2)) => {
        unify(env, choices1, choices2)
      }
      | (Note(note1), Note(note2)) => {
        note1 == note2
      }
      | (Duration(duration1, expr1), Duration(duration2, expr2)) => {
        duration1 == duration2
        && unify(env, expr1, expr2)
      }
      | _ => false
    }
  }
}

// let f
// (x | y) = (5 | 6)
// x = (5 | 6) | y = (5 | 6)

// (x | y) = f (z | w)
// x = f (z | w) | y = f (z | w)
// x = f z | x = f w | y = z | y = w

// let x in loop() = x 
// loop() = id(x)


//            x             x
// let y in y = 4 in let x in ((x = 5) in x | (x = 6) in x)
// [                                                      ]  y = 4
//                            [             ]                x = 5
//                                            [           ]  x = 6

