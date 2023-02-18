# Pling

_Ever wanted to program with one hand? We have and that's why we made Pling._

Pling is a programming language that is designed to be used with one hand. It is functional
and has a very simple syntax. Since it is developed in [48h](https://github.com/langjam/jam0004), it is also very easy to learn.

If you have never attempted to program with one hand, let us tell you that it is not easy
since you constantly have to press modifier keys while typing. Pling has a token set that
can be typed without any modifier keys (assuming you have a US keyboard layout).

## Why though?

This time's theme for the [LangJam](https://github.com/langjam/jam0004) was "The sound(ness) of one hand typing".
This is, as always, a very confusing theme. We decided to interpret it as "programming with one hand", but we also
implemented some other aspects of the theme.

Here is our list of requirements for the language:
1. The language should be able to be typed with one hand (no modifier keys) 
2. The language should be able to generate (music, sound effects, etc.), play and read (microphone input) sound
3. The language should match the theme of Koans (Impossible to solve, but you can learn from it)

Especially the last requirement is a bit of a challenge for the programmer since it just discards many error messages
and runs whatever it can. This is why we decided to implement a "debug mode" that can be enabled adding the `--debug` flag
to the interpreter. More on that later.

## How to use

### Installation

Since Pling is written in Java, you'll need to have Java installed on your system. We developed Pling using Java 17 (GraalVM),
but it should work with any Java 17+ version. You can download GraalVM [here](https://www.graalvm.org/downloads/).

After you have installed Java, you should install maven. Here are some instructions for [Linux](https://maven.apache.org/install.html) and [Windows](https://phoenixnap.com/kb/install-maven-windows).

Now you can clone the repository and build the project using maven:
```bash
git clone https://github.com/Sync-Private/jam0004.git
cd jam0004
cd Pling
cd engine
mvn clean install
```

You now have a runnable jar file in the `target` directory. You can run it using the following command:
```bash
java -jar target/engine-1.0-SNAPSHOT.jar [file] [args]
```

### Usage
TODO

```
fun sine #amplitude #frequency [
    // code to generate a sine wave
    ret sinewave; // returns the sine wave
]
```