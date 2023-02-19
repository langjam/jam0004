@module("./editor") external registerInterpreter: (string => unit) => unit = "registerInterpreter"
@module("./editor") external registerRunClick: (unit => unit) => unit = "registerRunClick"
@module("./editor") external displayNote: string => unit = "displayNote"

@module("./player") external playNoteRaw: (string, string) => unit = "playNote"

let editorText = ref("")

registerInterpreter(text => editorText := text)

let playNote = (duration, pitch, octave) => {
  playNoteRaw(
    Syntax.noteToString(pitch) ++ Belt.Int.toString(octave),
    Belt.Int.toString(duration) ++ "n",
  )
  Js.log3(duration, Syntax.noteToString(pitch), octave)
  displayNote(Syntax.noteToString(pitch))
}

registerRunClick(() => {
  let text = editorText.contents

  try {
    Driver.playExpr(~playNote, text)
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
  | Parser.Error => displayNote("Parse error")
  | error =>
    displayNote(
      "ERROR: " ++
      Belt.Option.getWithDefault(Js.Json.stringifyAny(error), "<Unable to stringify value>"),
    )
  }
})
