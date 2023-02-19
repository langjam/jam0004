
# Numpad

A dynamically typed expression language that can be programmed using just one hand on the numpad.

## Hello world

The following program prints "Hello world!" and then calculates 1+1:

```
1..*.72..*.101..*.108..*.108..*.111..*.32..*.119..*.111..*.114..*.108..*.100..*.33..*.10..1+1
```

Easy right? Next we'll try sorting a list with 5 elements:

```
1..100//.*2..*3./
2..5
3../.20..40..11..1..16./
100..101-**100..102-+*/.*100./+1..103-0..104-0..105-0..*106
106..**/.102..107./++/.*101./+-*103
107..**/.111..108./++/.*101./+-*104
108..**/.109..110..110./+1++/.*/.*102./+*103./+-*/.*102./+*104
109..105-*/.*102./+*103.././.*102./+*103./-*/.*102./+*104.././.*102./+*104./-*105..*110
110..104-1+*104..*107
111..103-1+*103..104-0..*106
```

## Build

In order to build the compiler from source, run the following:

```
cargo install --path .
```

This should add `numpad` to your *~/.cargo/bin* or equivalent. To uninstall it again, run:

```
cargo uninstall numpad
```

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

### [Read the full documentation on Numpad's website](https://sliv9.github.io/numpad/)
