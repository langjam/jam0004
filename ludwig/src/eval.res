open Syntax
open Util

type evalError = 
  | UnboundVariable(string)
  | TryingToCallNonFunction(value)

exception EvalError(evalError)


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
  | Var(name) => 
    switch Belt.Map.String.get(env.variableIdentities, name) {
    | None => raise(EvalError(UnboundVariable(name)))
    | Some(unique) => evalVariable(env, name, unique)
    }
  | Lambda(name, body) => {
    Closure(env, name, body)
  }
  | Let(name, rest) =>
    // This creates a new, currently unbound variable with a fresh identity
    let unique = Unique.fresh ()
    
    let updatedEnv = { ...env, variableIdentities : Belt.Map.String.set(env.variableIdentities, name, unique) }

    eval(updatedEnv, rest)
  | LetConst(name, rest) =>
    let unique = Unique.fresh ()
    let updatedEnv = { ...env, variableIdentities : Belt.Map.String.set(env.variableIdentities, name, unique) }
    insertVarValue(updatedEnv, unique, VConst(unique))

    eval(updatedEnv, rest)

  | Unify(expr1, expr2, rest) =>
    if unify(Thunk(env, expr1), Thunk(env, expr2)) {
      eval(env, rest)
    } else {
      VFail
    }
  | App(funExpr, argExpr) => {
    let funValue = eval(env, funExpr)
    evalApp(funValue, Thunk(env, argExpr))
  }
  | Choice(leftChoice, rightChoice) => {
    let leftValue = eval(newEvalScope(env), leftChoice)
    let rightValue = eval(newEvalScope(env), rightChoice)
    switch (leftValue, rightValue) {
    | (VFail, _) => rightValue
    | (_, VFail) => leftValue
    | (_, _) => VChoice(leftValue, rightValue)
    }
  }
  | Sequentialize(choices) => raise (Panic("TODO"))
  | Fail => VFail
  // All of these are already in whnf
  | Cons(headExpr, tailExpr) => VCons(Thunk(env, headExpr), Thunk(env, tailExpr))
  | EmptyList => VEmptyList 
  | Note(note) => VNote(note) 
  | Duration(duration, expr) => raise (Panic ("TODO"))
}

and evalApp : _ => _ => value = (funValue, argValue) =>
  switch tryReduceStuck(funValue) {
    | Thunk(thunkEnv, expr) => 
      evalApp(eval(thunkEnv, expr), argValue)
    | (VStuckVar(_) | VStuckApp(_) | VConst(_)) as stuckValue => 
      VStuckApp(stuckValue, argValue)
    | Closure(closureEnv, closureParam, closureBody) => {
      let paramUnique = Unique.fresh ()

      let updatedEnv = { ...closureEnv
                       , variableIdentities : Belt.Map.String.set(closureEnv.variableIdentities, closureParam, paramUnique) 
                       }
      insertVarValue(updatedEnv, paramUnique, argValue)
      eval(updatedEnv, closureBody)
    }
    | (VNote(_) | VCons(_) | VEmptyList) as nonFunctionValue => {
      raise (EvalError(TryingToCallNonFunction(nonFunctionValue)))
    } 
    | VFail => VFail
    | VChoice(leftChoice, rightChoice) => {
      let leftReduced = evalApp(leftChoice, argValue)
      let rightReduced = evalApp(rightChoice, argValue)
      switch (leftReduced, rightReduced) {
        | (VFail, _) => rightReduced
        | (_, VFail) => leftReduced
        | _ => (VChoice(leftReduced, rightReduced))
      }
    }
}

and evalVariable = (env, name, unique) => {
  let rec go = scopes => switch scopes {
    | list{} => {      
      VStuckVar(env, name, unique)
    }
    | list{scope, ...rest} => switch Belt.HashMap.get(scope, unique) {
      // There is no binding in this scope, but it might still be bound higher up somewhere
      | None => go(rest)
      | Some(Thunk(thunkEnv, expr)) =>
        let value = eval(thunkEnv, expr)
        // Update the variable so that future evaluations don't need to recompute the previous eval step.
        Belt.HashMap.set(scope, unique, value)
        value
      | Some(value) => value
    }
  }
  go(env.variableValueScopes)
}

and unify : (value, value) => bool = (value1, value2) => switch (value1, value2) {
  | (VStuckVar(varEnv, _name, unique), value)
  | (value, VStuckVar(varEnv, _name, unique)) => {
      insertVarValue(varEnv, unique, value)
      true
  }
  | (VStuckApp(fun1, arg1), VStuckApp(fun2, arg2)) => {
    unify(fun1, fun2)
    && unify(arg1, arg2)
  }
  | (VChoice(_), VChoice(_)) => raise (Panic ("TODO"))
  | (VEmptyList, VEmptyList) => true
  | (VCons(head1, tail1), VCons(head2, tail2)) => {
    unify(head1, head2)
    && unify(tail1, tail2)
  }
  | (VNote(note1), VNote(note2)) => {
    note1 == note2
  }
  | (Thunk(thunkEnv, thunkExpr), value) => {
    unify(eval(thunkEnv, thunkExpr), value)
  }
  | (value, Thunk(thunkEnv, thunkExpr)) => {
    unify(value, eval(thunkEnv, thunkExpr))
  }
  | (VFail, _) | (_, VFail) => false
  | (VConst(unique1), VConst(unique2)) => unique1 == unique2
  | _ => false
}

and tryReduceStuck = value => switch value {
  | VStuckVar(varEnv, name, unique) => evalVariable(varEnv, name, unique)
  | VStuckApp(fun1, arg1) => evalApp(fun1, arg1)
  | value => value
}


let makeEnvironment = () => {
  variableValueScopes: list{ Belt.HashMap.make(~hintSize=10, ~id=module(Unique.Hashable)) },

  variableIdentities: Belt.Map.String.empty
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

