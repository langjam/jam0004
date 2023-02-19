package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.executor.Builtin;
import dev.syncclient.pling.executor.FunctionStateNode;
import dev.syncclient.pling.executor.StateNode;

public class BasicBuiltins implements Builtin {
    @Override
    public void load(StateNode root) {
        root.children().add(new FunctionStateNode("print", "Prints a string to the console", "#print <...any>", (args) -> {
            for (Object arg : args) {
                System.out.print(arg);

                if (arg != args.get(args.size() - 1))
                    System.out.print(" ");
            }

            System.out.println();

            return null;
        }));

        root.children().add(new FunctionStateNode("printnf", "Prints a string to the console without a newline at the end", "#printnf <...any>", (args) -> {
            for (Object arg : args) {
                System.out.print(arg);

                if (arg != args.get(args.size() - 1))
                    System.out.print(" ");
            }

            return null;
        }));

        root.children().add(new FunctionStateNode("add", "Adds two numbers", "#add [num1] [num2] -> [result]", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("add takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("add takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() + ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("sub", "Subtracts two numbers", "#sub [num1] [num2] -> [result]", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("sub takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("sub takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() - ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("mul", "Multiplies two numbers", "#mul [num1] [num2] -> [result]", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("mul takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("mul takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() * ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("div", "Divides two numbers", "#div [num1] [num2] -> [result]", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("div takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("div takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() / ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("gt", "Returns 1 if the first argument is greater than the second, else 0", "#gt [num1] [num2] -> [result]", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("gt takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("gt takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() > ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("lt", "Returns 1 if the first argument is less than the second, else 0", "#lt [num1] [num2] -> [result]", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("lt takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("lt takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() < ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("eq", "Returns 1 if the first argument is equal to the second, else 0", "#eq [item1] [item2] -> [result]", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("eq takes exactly 2 arguments");

            return args.get(0).equals(args.get(1));
        }));

        root.children().add(new FunctionStateNode("neq", "Returns 1 if the first argument is not equal to the second, else 0", "#neq [item1] [item2] -> [result]", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("neq takes exactly 2 arguments");

            return !args.get(0).equals(args.get(1));
        }));


        root.children().add(new FunctionStateNode("sleep", "Sleeps for a specified amount of time (in ms)", "#sleep [time]", (args) -> {
            if (args.size() != 1)
                throw new IllegalArgumentException("sleep takes exactly 1 argument");

            if (!(args.get(0) instanceof Number))
                throw new IllegalArgumentException("sleep takes exactly 1 number");

            try {
                Thread.sleep(((Number) args.get(0)).longValue());
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            return null;
        }));
    }

    @Override
    public String description() {
        return "Basic builtins";
    }
}
