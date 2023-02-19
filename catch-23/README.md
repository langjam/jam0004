# Catch-23

The language has keywords and operators formed out of the glyphs below only:
+ !@#$%^&*()[]{}<>,.;:?|+-="'~/\

Because the theme is interpreted as being nonsense, the language is full of ambiguities and contradictions, which all amount to nonsense.

## Variables and Types

The language doesn't come with traditional types, instead it comes in three types:
+ Thing32, written as `#` and a Thing32 array by extension: `#[]`

Those types can represent anything that is a floating point number, an integer number and a character.
To declare a variable, type the variable name then the type following a colon. A variable name can only contain 2 characters which are alphanumeric.
```
@in : #
@sr : #[]
```
Respectively: int/float and string.

To assign it a value, you need to reference it first by using the `$` and then you can type the value using octal numbers inside brackets. Boolean variables use ! for false instead.
```
$in[5]
$db[7.235436345665]
$sr[100, 150, 154, 154, 157, 40, 127, 157, 162, 154, 144]
$bo[!(!)]
```
There is one exception here and it is that variables can't be directly assigned a value of 1. Instead, one must use the bitwise complement operator ~ to invert a 0.
In the case of a boolean, the only way to obtain a true is to invert a false by inverting the result with the not operator using the invertion notation of !(\<boolean expression\>) as shown above.

## Comments
Comments are \\\ for single line and \*\\ \\* for multiline.

```
*\
this is
a multiline
comment
\*

\\ this is a single line comment
```

## Operators
Float operators treat both operands as if they were valid floats without casting the values to float.
Integer operators treat both operands as if they were valid integers without casting the values to integer.
One cannot mix types with operators, so you couldn't write 2 + 2.1 for example. Well it isn't forbidden, but it will assume that 2.1 is an integer.

Operators are infix and there is no precedence, meaning the operators are evaluated in order of appearance, so 2 + 1 * 2 would return 6 for example.

|operator|input type|output type|params qty|desc
|-|-|-|-|-|
|\+|Integer|Integer|2|Returns the sum of two integers|
|\-|Integer|Integer|2|Returns the difference of two integers|
|\*|Integer|Integer|2|Returns the product of two integers|
|/|Integer|Integer|2|Returns the quotient of two integers|
|%|Integer|Integer|2|Returns the remainder of a division between two integers|
|\||Integer|Integer|2|Returns the bitwise OR'd value of two integers|
|&|Integer|Integer|2|Returns the bitwise AND'd value of two integers|
|">|Integer|Integer|2|Returns the right shifted value of two integers|
|"<|Integer|Integer|2|Returns the left shifted value of two integers|
|~|Integer|Integer|1|Returns the complement 1 of an integer|
|-|Integer|Integer|1|The integer becomes negative|
|''|Integer|Float|1|The integer is casted to float|
|'+|Float|Float|2|Returns the sum of two floats|
|'-|Float|Float|2|Returns the difference of two floats|
|'*|Float|Float|2|Returns the product of two floats|
|'/|Float|Float|2|Returns the quotient of two floats|
|'-|Float|Float|1|The float becomes negative|
|"|Float|Integer|1|The float is casted to integer|
|>|Integer|Boolean|2|Returns true if left is greater than right|
|<|Integer|Boolean|2|Returns true if left is lower than right|
|==|Integer|Boolean|2|Returns true if left is equal to right|
|<>|Integer|Boolean|2|Returns true if left is different from right|
|'>|Float|Boolean|2|Returns true if left is greater than right|
|'<|Float|Boolean|2|Returns true if left is lower than right|
|'=|Float|Boolean|2|Returns true if left is equal to right|
|><|Float|Boolean|2|Returns true if left is different from right|
|&&|Boolean expression|Boolean|2|Returns true if both expressions evaluate to true|
|\|\||Boolean expression|Boolean|2|Returns true if either expression evaluates to true|
|!|Boolean|Boolean|1|Returns the opposite of the boolean|

## Control Flow

catch-23, due to being contradiction-oriented, comes with statements that more or less don't do anything without a Goto, which is written as `~>`.
Break, which is written as `<~`, can be used to break out of Dont, Never. 

catch-23 is contradiction-oriented because it Donts and Never are basically if (false) and while (false) and no control flow can be exucted without being in either one or themselves, which also reflects the name of it being a catch-22. 

### Unless, Else Unless, Else

Unless, written as `?(<boolean expression>)` is the same as an inverted if statement in C: `if (!(<boolean expression>))`. Unless can only be used directly inside Dont or another Unless/Else Unless/Else. It cannot be used in a block of code that isn't any of those cases even if that block of code is inside one of those.
```
?(!($vr > 0))
{
  \\ code here 
}
```

### Until
Until, written as `::(<boolean expression>)` is the same as an inverted while statement in C: `while (!(<boolean expression>))`. Until can only be used directly inside other loops. It cannot be used in a block of code that isn't a loop even if that block of code is inside one.

### Dont

A Dont, written as `:;`, is a block of code that isn't executed. However, if it is being executed, it will run the code once then exit the scope that was created by the Dont. The only way to execute the code inside a Dont is by Goto using a label inside the Dont:
```
~> my_dont
:;
{
  |> my_dont
  \\ code here
}
```

### Never

A Never, written as `::`, is a loop that is never executed. However, if it is being executed, it will run the code forever without ever exiting scope it created. It never gets out so to speak.The only way to execute the code inside a Never is by Goto using a label inside the Never:
```
~> my_never
::
{
  |> my_never
  \\ code here
}
```
