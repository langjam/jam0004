@module("./editor") external registerInterpreter : (string => unit) => unit = "registerInterpreter"
@module("./editor") external registerRunClick : (unit => unit) => unit = "registerRunClick"
@module("./editor") external displayNote : string => unit = "displayNote"

let editorText = ref("")

registerInterpreter(text => editorText := text)

registerRunClick(() => {
    let text = editorText.contents

    let lexbuf = Lexing.from_string(text)

    let expr = Parser.main (Lexer.token, lexbuf)

    let stringified = switch Js.Json.stringifyAny(expr) {
        | None => "Error stringifying expression"
        | Some(str) => str
    }

    displayNote(stringified)
})

