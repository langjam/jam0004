module NoteSet = Set.Make({
    type t = Syntax.note
    let compare = (x, y) => {
        let xInt : int = Obj.magic(x)
        let yInt : int = Obj.magic(y)
        compare(xInt, yInt)
    }
})

@module("./player") external sixteenthNote : unit => int = "sixteenthNote"

type driverError = 
    | EvalError(Eval.evalError)
    | InvalidNote(Syntax.value)

exception DriverError(driverError)


let playExpr = (~playNote, programText) => {
    let lexbuf = Lexing.from_string(programText)

    let expr = Parser.main (Lexer.token, lexbuf)
    
    // 1 tick ^= 1/16th note
    let tick = ref(0)

    let notesThisTick = ref(list{})

    let continuations = ref(list{})

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

                | VChoice(VNote(_) as leftChoice, rightChoice) => {
                    evaluateNotes(leftChoice, () => ())
                    evaluateNotes(rightChoice, cont)
                }
                | VChoice(leftChoice, VNote(_) as rightChoice) => {
                    evaluateNotes(leftChoice, cont)
                    evaluateNotes(rightChoice, () => ())
                }
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

                | VNote(note) => 
                    notesThisTick := list{note, ...notesThisTick.contents}
                    continuations := list{(tick.contents + 2, cont), ...continuations.contents}
            }
        }

        evaluateNotes(Thunk(env, expr), () => ())

        tick := tick.contents + 1

        let rec playCurrentNotes = () => {
            let deduplicatedNotes = NoteSet.elements (NoteSet.of_list(notesThisTick.contents))

            List.iter(note => playNote(note), deduplicatedNotes)
            notesThisTick := list{}
            
            let continuationsThisTick = continuations.contents
            continuations := list{}

            let rec runReadyContinuations = continuations => switch(continuations){
            | list{} => list{}
            | list{(tickToContinue, cont), ...rest} => {
                    Js.log2(tick.contents, tickToContinue)
                    if (tickToContinue == tick.contents){
                        cont()
                        runReadyContinuations(rest)
                    } else {
                        list{(tickToContinue, cont), ...runReadyContinuations(rest)}
                    }
                }
            }

            let skippedContinuations = runReadyContinuations(continuationsThisTick)
            continuations := List.append(continuations.contents, skippedContinuations)

            switch continuations.contents {
            | list{} => ()
            | _ => let _ = Js.Global.setTimeout(() => {
                    tick := tick.contents + 1
                    playCurrentNotes()
                }, sixteenthNote())
            }
        }
        playCurrentNotes()

    } catch {
    | Eval.EvalError(error) => raise(DriverError(EvalError(error)))
    }
}
