# Command line interface

Numpad is both a compiler and a REPL.

## Run source code

By convention the extension for Numpad programs is `.num`:

```
numpad examples/hello.num
```

## Start a REPL

Running numpad with no arguments starts the REPL. A prompt will appear, starting with `| `, where you can type in your code:

```
numpad
|
```

## Input
Although you can use both hands and an entire keyboard to program... what fun is that?

Using only the numpad, the following keys are available to you:

  - Numbers : `0 1 2 3 4 5 6 7 8 9`
  - Dot : `.`
  - Operators : `+ - * /`
  - Cursor movement : `← → Home End`
  - History : `↑ ↓`
  - Editing : `Del`
  - Input   : `Enter`
  - Terminal dependent : `Insert PgDn PgUp`

Remember to use `NumLock` to toggle between characters and actions.

Press `Enter` twice to evaluate from the entry point:

```
numpad
| 1..*2
| 2..5
|
Output: (5)
|
```

End the REPL session by typing 4 dashes at the start of the line:

```
numpad
| ----
````

The first time you run `numpad`, it will create a `history.txt` file in the currenct directory.
You can use the arrow keys to browse your REPL input history while the REPL is running.

To run the REPL after passing in a source file, use the `--repl` flag:

```
numpad hello.num --repl
```

To get large amounts of debug information, use the `--verbose` flag:

```
numpad --verbose
| 1..*2
| 2..5
| 
TRACE - "1"	| Number 
TRACE - ".."	| Separator 
TRACE - "*"	| Star 
TRACE - "2"	| Number 
TRACE - ""	| Enter 
TRACE - "2"	| Number 
TRACE - ".."	| Separator 
TRACE - "5"	| Number 
TRACE - ""	| Enter 
TRACE - 
TRACE - Label : 
TRACE - 	Int(1)
TRACE - 	Sep
TRACE - 	Unary(Fetch)
TRACE - 	Int(2)
TRACE - Label : 
TRACE - 	Int(2)
TRACE - 	Sep
TRACE - 	Int(5)
TRACE - 
TRACE - 1:	Fetch((2))
TRACE - 2:	(5)
TRACE - 
TRACE - Evaluating 1: Fetch((2))
TRACE - 
TRACE - Eval :: Fetch((2))
TRACE - Access register 2: (5)
Output: (5)
|
```

You can combine the `--verbose` and `--repl` flags:

```
numpad hello.num --repl --verbose
```

You might be interested in debug information for a specific module.

Use `--log-module=numpad::<module>`
in combination with `--verbose`
where module is one of the project modules:
  - lexer
  - parser
  - machine

For example, to get only lexer output:

```
numpad --verbose --log-module=numpad::lexer
| 1..*2
| 2..5
| 
TRACE - "1"	| Number 
TRACE - ".."	| Separator 
TRACE - "*"	| Star 
TRACE - "2"	| Number 
TRACE - ""	| Enter 
TRACE - "2"	| Number 
TRACE - ".."	| Separator 
TRACE - "5"	| Number 
TRACE - ""	| Enter 
TRACE - 
TRACE - Label : 
TRACE - 	Int(1)
TRACE - 	Sep
TRACE - 	Unary(Fetch)
TRACE - 	Int(2)
TRACE - Label : 
TRACE - 	Int(2)
TRACE - 	Sep
TRACE - 	Int(5)
Output: (5)
| 
```
