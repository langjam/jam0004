type driverError = 
    | EvalError(Eval.evalError)
    | InvalidNote(Syntax.value)

exception DriverError(driverError)


let playExpr = (~playNote, programText) => {
    let lexbuf = Lexing.from_string(programText)

    let expr = Parser.main (Lexer.token, lexbuf)
    
    try {
        let env = Eval.makeEnvironment()

        let rec evaluateNotes = (value, cont) => {
            switch value {
                // This is a free variable (otherwise it would have been substituted by eval), 
                // so we cannot know how to play it
                | (Syntax.VStuckVar(_) 
                | Closure(_)
                | VStuckApp(_)
                | VConst(_)) as value => raise(DriverError(InvalidNote(value)))

                | Thunk(thunkEnv, expr) => evaluateNotes(Eval.eval(thunkEnv, expr), cont)

                | VChoice(leftChoice, rightChoice) => {
                    evaluateNotes(leftChoice, cont)
                    evaluateNotes(rightChoice, cont)
                }
                | VCons(headValue, tailValue) => {
                    evaluateNotes(headValue, () => {
                        evaluateNotes(tailValue, cont)
                    })
                }
                | VEmptyList => cont()

                // TODO: Should we display an (error?) message on failure or should we just stop playing?
                | VFail => cont()

                | VNote(note) => playNote(note, ~onComplete=cont)
            }
        }
        evaluateNotes(Thunk(env, expr), () => ())

    } catch {
    | Eval.EvalError(error) => raise(DriverError(EvalError(error)))
    }
}
