package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.executor.Builtin;
import dev.syncclient.pling.executor.FunctionStateNode;
import dev.syncclient.pling.executor.StateNode;

public class BasicBuiltins implements Builtin {
    @Override
    public void load(StateNode root) {
        root.children().add(new FunctionStateNode("print", "Prints a string to the console", (args) -> {
            for (Object arg : args) {
                System.out.print(arg);

                if (arg != args.get(args.size() - 1))
                    System.out.print(" ");
            }

            System.out.println();

            return null;
        }));

        root.children().add(new FunctionStateNode("add", "Adds two numbers", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("add takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("add takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() + ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("sub", "Subtracts two numbers", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("sub takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("sub takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() - ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("mul", "Multiplies two numbers", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("mul takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("mul takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() * ((Number) args.get(1)).doubleValue();
        }));

        root.children().add(new FunctionStateNode("div", "Divides two numbers", (args) -> {
            if (args.size() != 2)
                throw new IllegalArgumentException("div takes exactly 2 arguments");

            if (!(args.get(0) instanceof Number) || !(args.get(1) instanceof Number))
                throw new IllegalArgumentException("div takes exactly 2 numbers");

            return ((Number) args.get(0)).doubleValue() / ((Number) args.get(1)).doubleValue();
        }));
    }
}
