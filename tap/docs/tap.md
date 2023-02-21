## Syntax
Tap consists of 5 basic keywords each of which corresponds to a finger on your hand.
```
1. thumb
2. index
3. middle
4. ring (implemented after the deadline)
5. pinky
```

Then there are 3 modifiers which correspond to how hard you tap your finger.
```
1. soft
2. medium
3. hard
```

Then there the ```end``` keyword which you must use to indicate that you have lifted your finger.

## Thumb
You use you're thumb to control variables.
```
soft   - set variable
medium - get variable
hard   - initialize variable
```

## Index
You're index finger is used for -----.
```
soft   - print
medium - get user input
hard   - mathemetical operator
```
More on the [mathematical operations](#Mathematical-operator) later

## Middle
You're middle finger is used for logging and the harder you tap the higher the severity level is.
```
soft   - logging level info
medium - logging level warning
hard   - logging level error
```

## Ring
> Please keep in mind that I only started working on the ring finger the morning after the deadline

You're ring finger is used for loops.
```
soft   - start loop
middle - break out of loop
hard   - not implemented
```

## Pinky
You're pinky finger is used for if and else statements.
```
soft   - if
medium - then
hard   - else
```

## Mathematical operator
The mathematical operator is special in the way that you can do multiple things with it.

What can you do with it? You can
- Add
- Subtract
- Divide
- Multiply
- Concatenate strings

The mathematical operator does not follow the correct mathematical order and instead calculates from the inside out. You have to pass atleast 3 arguments to the index hard these are the ```operator```, ```value1``` and ```value2```.
There is no limit to how many arguments you can pass to ```index hard```.

[Example](examples/index_hard_numbers.tap):
```
// index soft is so we can see the result
index soft:
  index hard:
    // This gets calculated last
    "mul"
    6
    index hard:
      "add"
      index hard:
        "div"
        19
        2
      end
      index hard:
        "sub"
        64
        14
      end
    end
  end
end
```
Output:
```
357.0
```

[Example string concatenation](examples/index_hard_string_concatenation.tap):
```
// index soft is so we can see the result
index soft:
  index hard:
    "add"
    "Hello "
    "World"
    "!"
  end
end
```
Output:
```
Hello World!
```

See the [examples]() folder for all the examples.