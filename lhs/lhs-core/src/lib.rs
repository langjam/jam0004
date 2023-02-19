/*

    =
  = = =
= = = =
= = = =  =
= = = = ==
=========
= LHS ==
=======

Left Hand Side
by: xiuxiu62

A five digit state machine utilizing only the left half of your keyboard.
LHS runs on a state machine comprized of an N-sized two dimensional memory and
an M-sized stack.  Numerical values in the fifth radix are combined with
character encoded instructions into expression blocks, seperated by whitspace.

Your program may look like this
355e d15e d 2e g2a br15q

It may also look like this:
355e
d15e d
2e g2a
br15q

or even this:
355e
    d15e d
2e g2a
    br15q


You're limited only by where your left hand can take you.
On the other hand, you may be better off keeping things on one line.

----------------------
Numerical Instructions
----------------------
Numbers in LHS are in base 5, one for each finger on your left hand.
If you don't have five fingers on your left hand, then I appologize
for all the plays on words and you may want to pick another language.

Since we don't have access to the `0` key and 5 is not in base 5,
the `5` key is parsed into and functions as a zero.
Where decimal 10 is typically written as 20 -- in LHS it is written as 25.
Sorry.

Numbers act as repetition modifiers.
12a for instance, means move the memory pointer left 6 times.
Something like 12sde on the other hand, means move down, then left,
then increment the current cell, and do that 7 times.
Confused?  So am I.

Map:
1: 1
2: 2
3: 3
4: 4
5: 0


----------------------
Character Instructions
----------------------

TODO: better documentation for character instructions

Map:
q: decrement the value under the memory pointer
w: move memory pointer up
e: increment the value under the memory pointer
r: read, writes the current cell as a character to stdout
t: to, set the program counter to the supplied value and go to that expression frame

a: move memory pointer left
s: move memory pointer down
d: move memory pointer right
f: fetch, pop from stack and set cell
g: give, push to stack and set to 0

z: equals, stack pointer deref == memory pointer deref
x: not equals, stack pointer deref != memory pointer deref
c: copy, copies the current cell value onto the stack
v: void, zero out the current memory cell
b: brrr, loop decrementing the value under the pre iteration memory pointer until it is zero,
   setting the memory pointer to 0 before iterating

<s>: Nop, functions as an expression seperator

*/

pub mod language;
pub mod runtime;
pub mod util;

pub(crate) const BASE: u32 = 5;
