<script>
    import Footer from "../../Footer.svelte";
</script>

<div class="other">
    <div style="height: 100px"></div>

    <article>
        <h1>Introduction to Pling</h1>

        <h2>Hello, World</h2>

        <p>
            Pling is designed to be used with only one hand by using no modifier keys.
            Keep that in mind as you read through this tutorial.
        </p>

        <p>
            Create a new file ending in <code>.pling</code> and type the following:
        </p>
        <pre>
#print `Hello, World`;</pre>

        <p>
            Save the file and run it with <code>pling</code> or <code>java -jar</code>.
        </p>

        <p>
            You should see the following output:
        </p>
        <pre>Hello, World</pre>

        <p>
            So, let's break down what's going on here.<br/>
            First, we tell the interpreter to run a function using the <code>#</code> symbol.
            You'll see this symbol used a lot in Pling Code.
            Second, we name the function that we want to run, <code>print</code>. This is a built-in function that
            prints the given value to the console. You can find a list of all built-in functions and their
            documentation in the <a href="#/reference">reference</a>. Third, we pass the value that we want to print,
            in this case, <code>`Hello, World`</code>. This is a string literal, which is just some text.
            Lastly, we end the statement with a semicolon, <code>;</code>. This is required at the end of every
            statement.
        </p>

        <p>
            Now, let's try something a little more interesting.
        </p>

        <h2>Variables</h2>

        <p>
            Variables are used to store values in Pling. They are declared using the <code>var</code> keyword.
            Let's create a variable called <code>name</code> and set it to <code>`Pling`</code>.
        </p>
        <pre>var name = `Pling`;</pre>

        <p>
            Now, we can use the <code>name</code> variable in our <code>print</code> function.
        </p>
        <pre>
var name = `Pling`;
#print `Hello`, name;</pre>

        <p>
            The output should be:
        </p>
        <pre>Hello, Pling</pre>

        <p>
            Notice that we can pass multiple values to the <code>print</code> function.
            The values are separated by commas. But be careful, if you chain method calls,
            the commas will be assigned to the outermost method call.
        </p>

        <p>
            We can also change the value of a variable.
        </p>
        <pre>
var name = `Pling`;
name = `World`;
#print `Hello`, name;</pre>

        <p>
            The output should be:
        </p>
        <pre>Hello, World</pre>

        <p>
            We can also assign the return value of a function to a variable.
        </p>
        <pre>
var number1 = 1;
var number2 = 2;
var sum = #add number1, number2;
#print sum;</pre>

        <p>
            The output should be:
        </p>
        <pre>3.0</pre>
        <p>
            In Pling, all numbers are stored as doubles, so we get a decimal value.
        </p>

        <p>
            But only running from top to bottom is boring. Let's try adding some logic.
        </p>

        <h2>Control Flow</h2>

        <p>
            Control flow is used to change the flow of execution of a program.
            Pling has two types of control flow: <code>if</code> statements (and related <code>else</code> and
            <code>eif</code>
            statements) and <code>while</code> loops.
        </p>

        <h3>If Statements</h3>

        <p>
            If statements are used to execute code if a condition is met. Something is considered true if it is not an
            empty string or zero. Let's create a variable called <code>number</code> and set it to <code>1</code>.
        </p>
        <pre>
var number = 1;</pre>

        <p>
            Now, let's create an <code>if</code> statement that checks if <code>number</code> is equal to <code>1</code>.
        </p>
        <pre>
var number = 1;
var isOne = #eq number, 1;
#if isOne [
    #print `number is 1`;
]</pre>

        <p>
            The output should be:
        </p>
        <pre>number is 1</pre>

        <p>
            We can also use the <code>else</code> keyword to execute code if the condition is not met.
            But first, let's change the value of <code>number</code> to <code>2</code>.
        </p>
        <pre>
var number = 2;
var isOne = #eq number, 1;
#if isOne [
    #print `number is 1`;
] else [
    #print `number is not 1`;
]</pre>

        <p>
            The output should be:
        </p>
        <pre>number is not 1</pre>

        <p>
            We can also use the <code>eif</code> keyword to check multiple conditions.
        </p>
        <pre>
var number = 2;
var isOne = #eq number, 1;
var isTwo = #eq number, 2;
#if isOne [
    #print `number is 1`;
] eif isTwo [
    #print `number is 2`;
] else [
    #print `number is not 1 or 2`;
]</pre>

        <p>
            The output should be:
        </p>
        <pre>number is 2</pre>

        <h3>While Loops</h3>

        <p>
            While loops are used to execute code while a condition is met.
            Let's create a variable called <code>count</code> and set it to <code>0</code>.
        </p>
        <pre>
var count = 0;</pre>

        <p>
            Now, let's create a while loop that increments <code>count</code> until it is equal to <code>10</code>.
        </p>
        <pre>
var count = 0;
while #lt count, 10 [
    count = #add count, 1;
]
#print count;</pre>

        <p>
            The output should be:
        </p>
        <pre>10</pre>

        <p>
            In a world with only these tools, we can create some pretty cool things, but it would be nice to have some
            more tools to work with. Let's take a look at functions.
        </p>

        <h2>Functions</h2>

        <p>
            Functions are used to group code together and reuse it. Let's create a function called <code>sum</code>
            that adds two numbers together.
        </p>

        <pre>
func sum #number1, #number2 [
    ret #add number1, number2;
]</pre>

        <p>
            Now, we can call the <code>sum</code> function and pass it two numbers.
        </p>
        <pre>
func sum #number1, #number2 [
    ret #add number1, number2;
]
var result = #sum 1, 2;
#print result;</pre>

        <p>
            The output should be:
        </p>
        <pre>3.0</pre>

        <p>
            A function can also call itself using it's name.
        </p>

        <h2>The Standard Library</h2>

        <p>
            The standard library is a collection of functions that are included with Pling. It contains functions for
            working with strings and numbers, as well as functions for reading and writing files, playing sounds,
            reading input, http requests, and more. To use a module from the standard library, you must import it.
        </p>

        <pre>use fs;</pre>

        <p>
            Now, we can use the functions from the <code>fs</code> module. You can find the documentation for the
            standard library <a href="#/reference">here</a>. There are also some built-in functions that are always
            available. In Pling, these are called internal functions.
        </p>

        <hr>

        <p>
            And that's it for the basics. If you want to learn more, check out the <a href="#/reference">reference</a>
            and the <a href="https://github.com/Sync-Private/jam0004/tree/main/Pling/examples">examples</a>.
        </p>
    </article>
    <Footer/>

</div>

