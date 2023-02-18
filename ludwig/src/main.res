@module("./editor") external getEditorContent: unit => string = "getEditorContent"

Js.log(getEditorContent())
