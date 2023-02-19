# Pling

_Ever wanted to program with one hand? We have and that's why we made Pling._

# Table of Contents

1. [Introduction](#introduction)
2. [Why though?](#why-though)
3. [How to use](#how-to-use)
    1. [Installation](#installation)
        1. [Manual](#manual)
        2. [Automatic](#automatic)
    2. [Usage](#usage)
   3. [That's it already?](#thats-it-already)
   4. [License](#license)

## Introduction

Pling is a programming language that is designed to be used with one hand. It is functional
and has a very simple syntax. Since it is developed in [48h](https://github.com/langjam/jam0004), it is also very easy to learn.

If you have never attempted to program with one hand, let us tell you that it is not easy
since you constantly have to press modifier keys while typing. Pling has a token set that
can be typed without any modifier keys (assuming you have a UK keyboard layout).

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

#### Manual

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

#### Automatic

After the automatic installation, you can use the `pling` command to run Pling files.

If you use linux, use the following command to install Pling in this directory:
```bash
source pling.sh
```

If you use windows, use the following command to install Pling in this directory:
```batch
pling.bat
```

Attention: The windows variant seems to work only when you can only start pling from the directory where pling.sh is located.

### Usage

To start using Pling, you can either use the `pling` command or the `java -jar` command. The `pling` command is only available
after you have installed Pling using the automatic installation.

Running a Pling file is as simple as running any other file:
```bash
pling [file]
```

You can also add the `--debug` flag to enable the debugger:
```bash
pling [file] --debug
```
In this case, the debugger will be started before the program is executed and you can connect to it using telnet with the provided port.
If you only start one debugger, the following command should work:
```bash
telnet 127.0.0.1 9876
```
If you are using multiple debuggers, the debugger will tell you the port it is using.

## That's it already?

Nope! If you want to go beyond looking at the examples in the `examples` directory, you can read the [documentation](https://sync-private.github.io/jam0004/Pling/docs/).

## License

This project is licensed under the MIT License - see the [LICENSE](MIT-LICENSE.txt) file for details
