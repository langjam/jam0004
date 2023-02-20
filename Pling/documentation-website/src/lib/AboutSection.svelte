<article>
    <h1>Pling</h1>

    <p><em>Ever wanted to program with one hand? We have and that's why we made Pling.</em></p>

    <hr>
    <h1>Introduction</h1>
    <p>Pling is a programming language that is designed to be used with one hand. It is functional and has a very simple
        syntax. Since it is developed in 48h, it is also very easy to learn.</p>

    <p>If you have never attempted to program with one hand, let us tell you that it is not easy since you constantly
        have to press modifier keys while typing. Pling has a token set that can be typed without any modifier keys
        (assuming you have a UK keyboard layout).</p>

    <h1>Why?</h1>
    <p>
        This time's theme for the <a href="https://github.com/langjam/langjam">LangJam</a> was "The sound(ness) of one
        hand typing". This is, as always, a very confusing theme. We decided to interpret it as "programming with one
        hand", but we also implemented some other aspects of the theme.
    </p>

    <p>
        Here is our list of requirements for the language:
    </p>
    <ul>
        <li>The language should be able to be typed with one hand (no modifier keys)</li>
        <li>The language should be able to generate (music, sound effects, etc.), play and read (microphone input)
            sound
        </li>
        <li>The language should match the theme of Koans (Impossible to solve, but you can learn from it)</li>
    </ul>

    <p>
        Especially the last requirement is a bit of a challenge for the programmer since it just discards many error
        messages and runs whatever it can. This is why we decided to implement a "debug mode" that can be enabled adding
        the <code>--debug</code> flag to the interpreter. More on that later.
    </p>

    <h1>How to use</h1>
    <h2>Installation</h2>
    <p>Since Pling is written in Java, you'll need to have Java installed on your system. We developed Pling using Java
        17 (GraalVM), but it should work with any Java 17+ version. You can download GraalVM <a
                href="https://www.graalvm.org/downloads/">here</a>.</p>
    <p>
        After you have installed Java, you should install maven. Here are some instructions for <a
            href="https://maven.apache.org/install.html">Linux</a> and <a
            href="https://phoenixnap.com/kb/install-maven-windows">Windows</a>.
    </p>

    <h3>Automatic Installation</h3>
    <p>If you use linux, use the following command to install Pling in root directory:</p>
    <pre>source pling.sh</pre>
    <p>If you use windows, use the following command to install Pling in the root directory:</p>
    <pre>pling.bat</pre>

    <p>After the automatic installation, you can use the pling command to run Pling files.</p>
    <p>Attention: The windows variant seems to work only when you can only start pling from the directory where pling.sh
        is located.</p>

    <h3>Manual Installation</h3>
    <p>After you have installed maven, you can build Pling by running the following commands in the root directory of
        Pling:</p>
    <pre>
git clone https://github.com/Sync-Private/jam0004.git
cd jam0004
cd Pling
cd engine
mvn clean install</pre>

    <p>You now have a runnable jar file in the <code>target</code> directory. You can run it using the following
        command:</p>
    <pre>java -jar target/engine-1.0-SNAPSHOT.jar [file] [args]</pre>

    <h1>Usage</h1>

    <p>To start using Pling, you can either use the <code>pling</code> command or the <code>java -jar</code> command.
        The <code>pling</code> command is only available after you have installed Pling using the automatic
        installation.</p>

    <p>Running a Pling file is as simple as running any other file:</p>
    <pre>pling [file] [args]</pre>

    <p>You can also add the <code>--debug</code> flag to enable the debugger:</p>
    <pre>pling [file] --debug</pre>

    <p>In this case, the debugger will be started before the program is executed and you can connect to it using telnet
        with the provided port. If you only start one debugger, the following command should work:</p>
    <pre>telnet 127.0.0.1 9876</pre>

    <p>If you are using multiple debuggers, the debugger will tell you the port it is using.</p>

    <p>Want to learn Pling? Check out the <a href="#/intro">intro</a>!</p>
</article>
