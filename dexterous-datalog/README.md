# Dexterous Datalog

A [Datalog][0] implementation with no sinister secrets.

[0]: https://en.wikipedia.org/wiki/Datalog

It's Datalog but it won't let you use any identifier with letters typed with
your left hand on QWERTY. If it sees any left-handed letters, it skips them.
That means your output doesn't follow from your input, and it becomes unsound
if you use both hands!

I ran out of time to implement the actual _query_ part, so instead it just
prints out the whole universe of facts once it's known.

## Build and Install

Clone this repository with `git` and use `cargo` to build and install.

```sh
cargo build
cargo run
```

## Features

Usage: `dexterous-datalog [OPTIONS] [FILENAME]`

You can have it run a file by giving it one. It'll expand the rules to produce
the full universe of facts, and print them out. It's _very dumb_ about this, so
don't try anything to big.

It'll also start up a REPL unless you pass a `--query` argument, but since
queries are incomplete, there's not much to do.

Try `--help` too.

### Screenshot

Here's what this looks like _working on my machine™️_.

<img width="649" alt="A screenshot showing help, a diagnostic, and a demo file" src="https://user-images.githubusercontent.com/2024439/219977718-02e08b23-1e0b-485e-b809-514fa1dac2cf.png">

### Unfinished

- Queries aren't run, sadly. This would be almost identical to
  `data_set::Rule::next` too, but I just didn't have the time. Adding rules
  from the REPL would be pretty easy too.

- I wanted to add command line options to support different keyboard layouts,
  and maybe turn off the filter. Again, time constraints got to me. The
  skipping code is in `parser::name` if you want to try this with it off --
  just remove the `.map(...)`.

- The 'left-handed' warning isn't really printing. Not quite sure what I'm
  doing wrong with `miette`'s `#[related]` here. I pulled it out at the last
  second to do the filtering instead.

- Even without actually using `datafrog`'s magic sauce, there's a _lot_ I'm
  sure I could do to optimize this.

## Post-mortem

The plan was to have a full REPL, leaning on [`miette`][1] and [`chumsky`][2]
to make the UI work, and [`datafrog`][3] to do the heavy lifting for the
implementation. That's didn't quite work out.

[1]: https://github.com/zkat/miette
[2]: https://github.com/zesterer/chumsky
[3]: https://github.com/rust-lang/datafrog

I think the big take-away is that I took on more than I could finish. It's my
first time doing something like this, and the game jams I've done were all with
a team too. I spent a bit too much time on trying to be polished (repl,
diagnostics, etc) and not enough on the actual language implementation.

I probably could have saved a lot of time yesterday morning if I hadn't tried
to write a parser by hand in such an ad-hoc way the first day, but `¯\_(ツ)_/¯`

The theme was a bit tricky. I briefly explored languages in the hopes I could
write the _implementation_ in with only one hand. 

Datalog's neat, and I've wanted an excuse to play with it for a while, which
was a pretty big part of goign with this idea. Unfortunately, I didn't quite
have the time to work out how to break down rules systematically to work with
`datafrog` key-value restriction, so I just gave up about 4 hours before
submission time and try to just brute force the rules top-down by enumerating
all possible tuples and checking each sub-goal.

This was fun, but I'd probably aim smaller at the start next time, and only try
to add bells and whistles (like the repl) if there was time.

### Acknowledgements

Huge shout out to the authors of those crates: Frank McSherry (and others!),
zkat, and zesterer, and more. And JT for running this whole thing!
