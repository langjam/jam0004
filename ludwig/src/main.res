@module("./editor") external registerInterpreter: (string => unit) => unit = "registerInterpreter"
@module("./editor") external registerRunClick: (unit => unit) => unit = "registerRunClick"
@module("./editor") external displayNote: string => unit = "displayNote"

@module("./player") external playNoteRaw: (string, string, unit => unit) => unit = "playNote"

let editorText = ref("")

registerInterpreter(text => editorText := text)

let playNote = (note, ~onComplete) => {
  playNoteRaw(Syntax.noteToString(note), "4n", onComplete)
  Js.log(note)
}

registerRunClick(() => {
  let text = editorText.contents

  try {
    Driver.playExpr(~playNote, text)

    displayNote("Should be playing?")
  } catch {
  | Driver.DriverError(error) =>
    switch error {
    | InvalidNote(expr) =>
      displayNote(
        "Invalid note: " ++
        Belt.Option.getWithDefault(Js.Json.stringifyAny(expr), "<Unable to stringify value>"),
      )
    | EvalError(UnboundVariable(varname)) => displayNote("Unbound variable: " ++ varname)
    | EvalError(TryingToCallNonFunction(expr)) =>
      displayNote(
        "Trying to call non-function: " ++
        Belt.Option.getWithDefault(Js.Json.stringifyAny(expr), "<Unable to stringify value>"),
      )
    }
  | Js.Exn.Error(error) =>
    displayNote(
      "JS error: " ++ Belt.Option.getWithDefault(Js.Exn.message(error), "<No exception message>"),
    )
  | error =>
    displayNote(
      "ERROR: " ++
      Belt.Option.getWithDefault(Js.Json.stringifyAny(error), "<Unable to stringify value>"),
    )
  }
})
