
# Graphica

Graphica is a programming language designed to be typed with one hand.

It is based on stack languages, like forth of postscript.

# Gestures

run `python3 graphica/camera.py`

This will use opencv to turn on your camera and watch the tip of your index finger.

The editor will then show up, with hopefully a colorful circle.

Move your index finger to the circle, and stop when you get inside.
A Smaller circle will show up that says add. To add a node to the hovered node move your index finger to add.
This creates a child node growing from opposite of where you entered the circle.
Use your other hand to type `'hello 'world` in it.
You should see below it and the original circle the words hello world, seperated by a space.
go back to the original node and select `del`, this will remove our hello world.

Graphica was desinged to be typed with one hand and controlled with a finger.

# Language

## Special syntax

the text inside the node is split on spaces and then run.

comments start with `#` and run until the end or until another `#` is found

strings are written inside of square braces (`[ x ]` is `"x"`). You can also use `'x` if the string needs no spaces.

numbers start with a digit or `.` and are floating point if they contain a decimal point.

you can set variables by doing `,var-name` for any `var-name`
so `1 ,x` sets x to 1
the space is not strictly needed: `1,x` does the same

## Builtins

`str do`: runs a code string by splitting on spaces and evaulating each word. works with the strings given by `quote` and `[ thing ]` and alike.

### Stacks

* swap
* drop
* pop
* dup

### Control flow

* `str bool when` -> `str do` only if bool is true 

### Boolean Logic

bool bool -> bool
* `not`
* `and` or `&&` or `&`
* `or` or `||` or `|`
* `xor`
* `nand`

### Compares

any any -> bool
* `eq` or `<`
* `ne` or `!=` or `neq` or `~=`

int int -> int
* `lt` or `<`
* `gt` or `>`
* `le` or `<=` or `lte`
* `ge` or `>=` or `gte` 

### Maths
* `add` or `+` 
* `sub` or `-` 
* `mul` or `*` 
* `div` or `/` 
* `mod` or `%` 
* `pow` or `^

# Strings

* `[ x ] [ y ] cat` -> `[ x y ]`

# Varaibles

get by string
`'name get` 

set by string
`value 'name set` 

## Quote

if the text inside the node is just `quote` (or `quo` works too) the node's children are not run and instead written as a string that can later be evaluated with `do`
