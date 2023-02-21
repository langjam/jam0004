# Your Hand in Melody

A weakly-typed music scripting language.

```c
oscillator sine(): sample {
    return sin(phase())
}

oscillator saw(): sample {
    return phase() % TAU - 3dB
}

sound play(note: hz, duration: secs) {
    let RELEASE_TIME = 0.3
    let ATTACK_TIME = 0.3
    do t = 0s ; t < duration + RELEASE_TIME * 1s ; t + SAMPLE_PERIOD {
        let attack = min(t / ATTACK_TIME, 1)
        let release = 1 - (max(t - duration, 0.0) / RELEASE_TIME)
        for detune in [-0.1st, -0.05st, 0st, 0.05st, 0.1st] {
            let s = saw() at time_phase(t, note + detune)
            set! s = pan(s, detune / 1st)
            mix(attack * release * (s - 10dB))
        }
        next()
    }
}

sound main() {
    for note in [C4, D4, E4, F4, G4, A4, B4, C5] {
        play(note, 1/4)
        skip(1/4 * SAMPLE_RATE)
    }
    let maj = [0st, 2st, 2st, 1st, 2st, 2st, 2st, 1st]
    for root in [C4, D4, E4] {
        let note = root
        for interval: semitones in maj {
            set! note = note + interval
            play(note, 1/4)
            skip(1/4 * SAMPLE_RATE)
        }
    }
}
```

Read on for documentation and examples.

## Contents

- [Your Hand in Melody](#your-hand-in-melody)
  * [Contents](#contents) 
  * [Build and Usage](#build-and-usage)
  * [Overview](#overview)
    + [Structure](#structure)
    + [Comments](#comments)
    + [Statements](#statements)
    + [Expressions](#expressions)
    + [Types](#types)
      - [Coercions](#coercions)
  * [Reference](#reference)
    + [Functions](#functions)
      - [`phase(): number`](#phase-number)
      - [`choose(cond: bool, if_true: T, if_false: T): T`](#choosecond-bool-if_true-t-if_false-t-t)
      - [`dbg(n: number): number`](#dbgn-number-number)
      - [`pan(s: sample, azimuth: num): sample`](#pans-sample-azimuth-num-sample)
      - [`time_phase(time: seconds, freq: hertz): number`](#time_phasetime-seconds-freq-hertz-number)
      - [`mix(s: sample)`](#mixs-sample)`)
        * [Samples, the Sample Counter](#samples-the-sample-counter)
      - [`next()`](#next)`)
      - [`skip(n: number)`](#skipn-number)
      - [`sqrt(x: number): number`](#sqrtx-number-number)
      - [`sin(x: number): number`](#sinx-number-number)
      - [`cos(x: number): number`](#cosx-number-number)
      - [`pow(base: number, exponent: number): number`](#powbase-number-exponent-number-number)
      - [`exp(x: number): number`](#expx-number-number)
      - [`ln(x: number): number`](#lnx-number-number)
      - [`min(a: number, b: number): number`](#mina-number-b-number-number)
      - [`max(a: number, b: number): number`](#maxa-number-b-number-number)
    + [Constants](#constants)
      - [`SAMPLE_RATE: hertz = 44100`](#sample_rate-hertz--44100)
      - [`SAMPLE_PERIOD: seconds = 1/44100`](#sample_period-seconds--144100)
      - [`E: number`](#e-number)
      - [`PI: number`](#pi-number)
      - [`TAU: number`](#tau-number)
      - [`C4`, `A4`, `G♯5`, `[A-G][♯♭sf]?[0-9]: hertz`](#c4-a4-g5-a-gsf0-9-hertz)

## Build and Usage

To build, you will need [Rust](https://www.rust-lang.org/) installed. You will also need LLVM 15.0 installed in a way
that [llvm-sys](https://gitlab.com/taricorp/llvm-sys.rs/) should be able to find and link with it. This may be a pain
if you are using Windows, sorry about that.

This builds with Cargo, so you just need to run:

```shell
cargo build [--release]
```

And the executable will be at `./target/[release|debug]/yhim`, depending on whether you built with the release flag.
Run it with `--help` to see usage.

`yhim` can output LLVM IR (default), or a sound file directly (executing the generated IR with LLVM's JIT compiler).

## Overview

Your Hand in Melody (YHiM) is a music scripting language with a type system that isn't overly restrictive, but can help
you catch bugs, metaphorically leaving one hand free to deal with other things.

A YHiM program can be executed if it has a `main()` sound function, which will be played.
[Sample counter][sample counter] is also an essential read.
I highly recommend [VLC Media Player](https://www.videolan.org/vlc/) for playing the generated
audio files, since it automatically reopens them if they change.

### Structure

A YHiM file consists of a series of functions, which can be of three types.

```c
// a pure function, can take arguments, and optionally return a value
pure foo(x: num, y: num): num {
    return x + y
}

// an oscillator function, must return a sample; the return type hint isn't necessary
oscillator bar(freq: hertz): sample {
    // the phase() function is available in oscillator functions, returning the phase at
    // which the oscillator is being sampled at
    return sin(freq * phase())
}

// a sound function, must return void
sound baz(s: num, phase: num) {
    // the mix(s) function outputs the sample s as sound,
    // adding it to whatever was already output for that sample
    mix(s)
    mix(bar(440) at phase) // an oscillator can be sampled at a phase
    // the next() function proceeds to the next sample,
    // alternatively the skip(n) function skips ahead n samples
    next()
    // other sound functions can (only) be called from sound functions;
    // they will start at the current sample, but execute "asynchronously",
    // with its own calls to next() or skip(n) being invisible to the caller
    another_sound()
}
```

### Comments
```rust
// Comments can be line comments
/* or they can be
   multiline
   /* they can even be nested */ */
```

### Statements
The syntax of statements is similar to C, Java, JavaScript, and many others.

Other than line breaks, whitespace doesn't matter.

```c
pure foo(): num {
    // `let` statements allow you to define a variable
    let a = 10
    // you can specify a type
    let b: num = 20
    // it is also one place where types can get coerced 
    let c_secs: seconds = 30
    let d_num: num = c_secs
    /* invalid! cannot coerce between specific units
    let e_hertz: hertz = c_secs */
    
    // `set!` expressions let you set an existing variable
    set! a = 20
    // types still get coerced to the type of the existing variable,
    // even if this was inferred
    set! c_secs = 3
    /* invalid!
    set! c_secs = 20 hertz */
    
    // `for` blocks let you iterate over an array (and an array only)
    for x in [1, 2, 3, 4] {
        set! a = a + x
    }
    
    // `do` blocks let you loop more generally
    do i = 0 // initial binding
     ; i < 10 // continuing condition
     ; i + 1 // !!DIFFERENT TO C!! iteration expression,
             // `i` gets set to the result of the expression for the next loop
    {
       // do things
    }
    
    // there are no `if`s (or buts),
    // you should use the `choose(cond, if_true, if_false)` function instead
    // (or emulate them with `do` if you really must)

    // `return` statements can return a value, or nothing if the function
    // returns void
    return a
    /* valid only in a void function
    return */
    
    // you can also have a function call as a statement
    dbg(10)
    
    // statements must be separated by a semicolon or a line break
    let y = 10; let z = 20;
    set! y = y + z
}
```

### Expressions
```c
// numbers
10, 1.0, 1., .5, 1.2345
// numbers, but with units
10s, 440hz, 220 hertz, 6dB, 12st, 7 semitones
// variables
a, x, phase, freq, s?!, why??, _h12, C♯4, G♭5
// unary operators
!cond, -foo, +bar
// binary operators, and parentheses
(a + b) % TAU <= (c * d / e)
// arrays (must all have the same type)
[C4, D4, E4, F4, G4]
// function calls
min(a, b), sine() at t
```

### Types
YHiM has a handful of types, listed below.

Importantly: numerical types can be "dimensionless" (`num`)
or have units (`s`, `hz`, etc.), indicating what physical quantity they
represent.

- `void`: the return type of void functions
- `sample`: an audio [sample],
  contains left and right amplitudes of a sound
- `bool`, `boolean`: true or false, the result of a comparison
- `num` or `number`: a generic, dimensionless number, can freely be coerced
  into any units, or into a sample. Represented as 64 bit floating point.
  Possible units are:
  - `s`, `secs`, `seconds`: seconds, a unit of time 
  - `hz`, `hertz`: a frequency, 1 hertz is "one per second", typically for a frequency, or a pitch
  - `st`, `semitones`: relative Western units of pitch, can be added to or
    subtracted from (on the right) hertz (on the left); adding 1 semitone is equivalent to multiplying
    by 2^(1/12) (12 semitones is an octave)
  - `dB`, `decibels`: relative unit of amplitude, can be added to or subtracted from (on the right)
    a number (on the left) to scale it; adding 1 decibel is equivalent to multiplying by 10^(1/20)
    (6dB is approximately double/half)
- arrays (the type cannot be named): hold a fixed number of elements of the same type

#### Coercions
Types will be coerced if an expression produces a value of a different type to what
is expected. A `number` can be coerced to a `sample` or to any other numerical type.
All numerical types can be coerced to `number`.

If an expression *still* has the wrong units, you can simply divide by
1 in the units it already has to make it dimensionless
(or you can coerce it with a `let` statement).
Note that this is typically nonsensical.

For example if `time` is in seconds, and `freq` is in hertz,
`(time + freq)` would fail to type check, but you can make one
of them dimensionless by dividing, with `(time + freq/1hz)`.

## Reference
### Functions
#### `phase(): number`
Available in `oscillator` functions.

Returns the phase the oscillator was sampled at (with the `at` keyword).

#### `choose(cond: bool, if_true: T, if_false: T): T`
Returns `if_true` if `cond` is true, or `if_false` if it is false.
`if_true` and `if_false` can be any types, as long as they are the same.

#### `dbg(n: number): number`
Print `n` to standard output, for debugging.

#### `pan(s: sample, azimuth: num): sample`
Returns the sample panned left (-1 < `azimuth` < 0)
or right (1 > `azimuth` > 0),
making it sound as though it came from the given position.

#### `time_phase(time: seconds, freq: hertz): number`
Given a time and a frequency, return the phase an oscillator
of the given frequency should be at, at that time.
This is equivalent to the formula `((time * freq) % 1.) * TAU`.

#### `mix(s: sample)`
Available in `sound` functions.

Output the given sample at the time indicated by the [sample counter],
adding it to the currently recorded value for the sample, if any.

##### Samples, the Sample Counter
A [sample] is a unit of sound. Sound, as I hope you know, is a wave.
When this is represented digitally, the wave is split at equal intervals,
and the amplitude of the wave is taken at each point.

In YHiM, a `sound` function has an internal *sample counter*. Indicating the
current time that it is outputting samples for. The sample counter can be
increased with `next()` or `skip(n)`, and is observed by `mix(s)`.
When a `sound` function is called from another sound function, the sample counter
is inherited, but the `next()`s and `skip(n)`s of the callee will not
change the counter of the caller. In a sense, calls to sound functions
execute "asynchronously", the called function may have outputted samples
"in the future", but to the caller it returned "immediately".

[sample]: https://en.wikipedia.org/wiki/Sampling_(signal_processing)
[sample counter]: #samples-the-sample-counter

#### `next()`
Available in `sound` functions.

Increment the [sample counter] by one. Future calls to `mix` will output to the next sample,
and calls to other `sound` functions will start at the new sample counter.

#### `skip(n: number)`
Available in `sound` functions.

Increment the [sample counter] by `n`, rounded down.

#### `sqrt(x: number): number`
Returns the square root of `x`.

#### `sin(x: number): number`
Returns the sine of `x`.

#### `cos(x: number): number`
Returns the cosine of `x`.

#### `pow(base: number, exponent: number): number`
Returns `base` to the power of `exponent`.

#### `exp(x: number): number`
Returns [e]
to the power of `x`.

[e]: https://en.wikipedia.org/wiki/E_(mathematical_constant)

#### `ln(x: number): number`
Returns the natural logarithm of `x`.

#### `min(a: number, b: number): number`
Returns the minimum of `a` and `b`.
That is, `a` if it is smaller than `b`, or `b` otherwise.

#### `max(a: number, b: number): number`
Returns the maximum of `a` and `b`.
That is, `a` if it is larger than `b`, or `b` otherwise.

### Constants
#### `SAMPLE_RATE: hertz = 44100`
The number of samples per second.

#### `SAMPLE_PERIOD: seconds = 1/44100`
The duration of a sample in seconds.

#### `E: number`
Euler's number, [e].

#### `PI: number`
Archimedes' constant, π.

#### `TAU: number`
The full circle constant, τ, equal to 2π.

#### `C4`, `A4`, `G♯5`, `[A-G][sf]?[0-9]: hertz`
Piano key frequencies,
in [scientific pitch notation](https://en.wikipedia.org/wiki/Scientific_pitch_notation).

`A4` is exactly 440 hertz. `C4` is middle C, at approximately 261.626 hertz.
