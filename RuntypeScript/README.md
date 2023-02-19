**Original repo**: [iszn11/runtypescript](https://github.com/iszn11/runtypescript)

# RuntypeScript (aka rts)

RuntypeScript (aka rts) is a scripting language made in 48h for the fourth
langjam hosted at [langjam/jam0004](https://github.com/langjam/jam0004). The
theme was *The sound(ness) of one hand typing*.

The language is heavily inspired by TypeScript's type system, so being familiar
with it will make it easier to understand this language.

What I've noticed is that there are often two *islands*, so to speak.

### The type island

Example residents of the type island:

```ts
number
string
boolean
false
true
"foo"
"foo" | "bar"
0
0 | { foo: number[] }
```

These are valid types both in TypeScript and in RuntypeScript.

### The value island

Example residents of the value island:

```ts
false
true
"foo"
"bar"
0
{ foo: [1] }
```

These are valid values both in TypeScript and in RuntypeScript.

### The islands merge

Notice how there are some common parts between these two. Some things look
literally the same (like `true` type, which represents a type with only one
valid value, which happens to be `true`). **In RuntypeScript types and values
are identical, and not just syntatically: they literally are the same thing.**

Types are values. Values are types. When the islands merge, they become the same
thing and can interact in unprecedented ways. So, merging two previous code
snippets gives us this:

```
number
string
boolean
false
true
"foo"
"bar"
"foo" | "bar"
0
0 | { foo: number[] }
{ foo: [1] }
```

In RuntypeScript, these expressions can be used both as a type and as a value
(because, again, they are the same thing – there's really no distinction between
these too). This makes the following snippet a valid RuntypeScript code:

```
const a = number;
const b = string;
const c = boolean;
const d = false;
const f = true;
const g = "foo";
const h = "bar";
const i = "foo" | "bar";
const j = 0;
const k = 0 | { foo: number[] };
const l = { foo: [1] };

const aa: a = 2;     // has to be a number
const bb: b = "baz"; // has to be a string
const cc: c = false; // has to be a boolean
const dd: d = false; // etc.
const ff: f = true;
const gg: g = "foo";
const hh: h = "bar";
const ii: i = "foo"; // could be "bar" as well
const jj: j = 0;
const kk: k = { foo: [1, 2, 3] };
const ll: l = { foo: [1] };
```

This can lead to many silly ideas, like building objects or union types at
runtime (potentially based on user input or randomness) to later use them as
types. Check out [examples](./examples) directory for more.

## Building

This project is written in TypeScript and targets the Node.js runtime. Run these
commands to install dependencies and compile:

```
npm install
npx tsc --build
```

After building run `node .` to see additional flags or `node . FILE` to read,
compile and execure a script in `FILE`. These are the commands to run all of the
included examples:

```
node . ./examples/decltype.rts
node . ./examples/dictionary.rts
node . ./examples/extends.rts
node . ./examples/primes.rts
node . ./examples/signature.rts
node . ./examples/vector.rts
```

## Details

More detailed documentation can be found at the
[GitHub page](https://iszn11.github.io/runtypescript) for this project.
