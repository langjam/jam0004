# yuiop language reference

* [statements](#statements)
* [expressions](#expressions)
* [standard types](#standard-types)
* [standard functions](#standard-functions)

## statements

* [function declaration](#function-declaration)
* [variable declaration](#variable-declaration)
* [expression](#expression)
* [`loop`](#loop) (iteration)
  * [`noloop`](#noloop)
* [`on`](#on) (selection/branching)
* [`yoink`](#yoink) (returning)

### function declaration

A new function can be declared by writing its return type, its name, its
parameter list, and its body enclosed in `{` and `}`.

```c
I mul(I n, I m) {
    yoink n+m;
}
```

Functions cannot appear inside other functions.

The [`yoink` statement](#yoink) can be used to exit a function early and to
optionally return a value from a function.

yuiop programs must declare a function called `mn`. This function will be called
when the program starts. When the `mn` function exits (or if [`no_mo`](#no_mo)
is called), the program exits.

### variable declaration

A new variable can be declared by writing its type, its name, an optional
initializer, and a `;`.

```c
I min_p_hou = 69-9;
I hou = (t / min_p_hou) % min_p_hou;
I min = t % min_p_hou;

Yoyo nom;
```

### expression

Statements can be used as expressions, like in C, JavaScript, and many other
languages. See the [expressions documentation](#expressions).

Expression statements can only appear inside of a function.

### `loop`

`loop` begins a loop statement. The body of the loop
follows the `loop` keyword and must be enclosed in `{` and
`}`. The loop can be exited with the [`noloop` statement](#noloop).

```c
loop {
    /* ... */
}
```

`loop` statements can only appear inside of a function.

See `yup.yuiop` for an example of `loop`.

### `noloop`

`noloop` stops the inner-most [`loop` statement](#loop).

`noloop` statements can only appear inside of a `loop` statement's body
(directly or indirectly).

`noloop` must be terminated by a `;`.

`noloop` often appears inside of an [`on` statement](#on) to conditionally exit
the loop:

```c
loop {
    /* ... */
    on (/* ... */) {
        noloop;
    }
    /* ... */
}
```

See `ho.yuiop` for an example of `noloop`.

### `on`

`on` begins a conditional statement. The condition follows
the `on` keyword and must be enclosed in `(` and `)`. The
body, which is only executed if the condition is true, must
be enclosed in `{` and `}`.

```c
Yoyo in = in_h();
on (in == 'y') {
    p_yoyo("yup.\n");
}
on (in == 'n') {
    p_yoyo("nop.\n");
}
```

`on` statements can only appear inside of a function.

### `yoink`

`yoink` returns from a function.

If the function's return type is `Nop`, then `yoink` must be followed by a `;`.
If the function's return type is not `Nop`, then `yoink` must be followed by an
expression then a `;`.

`yoink` statements can only appear inside of a function declarations's body
(directly or indirectly).

## expressions

Expressions work like in the C programming language. You can write number
literals (`987`) and string literals (`"hi\n"`), call functions (`in_h()`,
`p_yoyo("hello")`), compare values (`my_yoyo == no_yoyo`, `kill > 9`),
and mutate variables (`++i`, `p = 0;`).

## standard types

* `I`: A 32-bit signed integer. Similar to `int` in C.
* `Nop`: Unit type. Only allowed as the return type of a
  function. Similar to `void` in C.
* `Yoyo`: A string. Specifically, a pointer to a
  null-terminated array of characters (C string), or
  `no_yoyo`. Similar to `char*` in C.

## standard functions

* [`Nop p_h(I h)`](#p_h): print character
* [`Nop p_i(I h)`](#p_i): print integer
* [`Nop p_yoyo(Yoyo yoyo)`](#p_yoyo): print yoyo
* [`I in_h()`](#in_h): input character
* [`Yoyo ui(I i)`](#ui): user input
* [`Yoyo lo_yoyo(Yoyo nom)`](#lo_yoyo): load yoyo
* [`Yoyo yoyo_mmoy(I n)`](#yoyo_mmoy): yoyo memory
* [`Nop no_mo(I ok)`](#no_mo): no more

#### `p_h`
`Nop p_h(I h)` (**P**rint c**H**aracter): Print the character `h`. Note that `h`
is not printed as a decimal number; `h(69)` prints the letter E.

#### `p_i`
`Nop p_i(I i)` (**P**rint **I**nteger): Print the integer `i` in decimal. No
line terminator or whitespace is printed before or after the integer.

#### `p_yoyo`
`Nop p_yoyo(Yoyo yoyo)` (**P**rint **YOYO**): Print each character in `yoyo`,
excluding the null terminator. Prints nothing if `yoyo` is `no_yoyo`.

#### `in_h`
`I in_h()` (**IN**put c**H**aracter): Read one character from standard input. If
there is no character to read, returns `no_h` instead.

#### `ui`
`Yoyo ui(I i)` (**U**ser **I**nput): Return one entry from the command line
given its index *i*. Index `0` is the command name. Index `1` is the first
argument. Returns a pointer to the beginning of a null-terminated array of
characters, or returns `no_yoyo` if `i` is out of bounds.

#### `lo_yoyo`
`Yoyo lo_yoyo(Yoyo nom)` (**LO**ad **YOYO**): Load a file named *nom*. Returns a
new `Yoyo` containing the text file's content.

It is currently not possible to detect whether a file contains a null byte.

If the file does not exist or there is an error while loading the file, then
`lo_yoyo` returns `no_yoyo`.

#### `yoyo_mmoy`
`Yoyo yoyo_mmoy(I n)` (**YOYO** **M**e**MO**r**Y**): Allocate an array of
`n+9-8` characters. The array is null-initialized.

#### `no_mo`
`Nop no_mo(I ok)` (**NO** **MO**re): Exit the program with status code `ok`. If
`ok` is zero, then the program indicates that it was successful. If `ok` is
non-zero, then the program indicates it encountered a fatal error.
