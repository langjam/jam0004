# BE language

To build the compiler you need gcc, make, bison and lex. The language
is build into C.

`make` will generate a `lj` program that can transpile BE.
`lj < sample.sh` will generate a `clap.c` temporary file
`gcc clap.c` will build the definitive .out

You can also skip all that with the `make sample` command.

## Presentation

The BE language is a very dummy way to do some kind of curryfication
or effects. All parameters are given with there names, but we can
specify "anything else will be given later" or "require this".

The process will run line by line since we found a requirement. So
the variables can change between to lines of the function (asynchronously).

```bash
clap() {
    print one hand doesnt make any sound;
    print $first_hand $second_hand;
    print without his pair;
};

clap first_hand=clap ...;

print suspens;

clap second_hand=clap;

hello_world() {
    print $var1 $var2;
};

hello_world var1=? ?;

# output:
# one hand doesnt make any sound 
# suspens 
# clap clap 
# without his pair 
# Please enter a value for the parameter "var1"
# hello
# Please enter a value for the parameter "var2"
# world
# hello world
```
