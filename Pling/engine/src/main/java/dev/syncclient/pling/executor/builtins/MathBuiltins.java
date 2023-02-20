package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.executor.Builtin;
import dev.syncclient.pling.executor.FunctionStateNode;
import dev.syncclient.pling.executor.StateNode;

public class MathBuiltins implements Builtin {
    @Override
    public void load(StateNode root) {
        root.children().add(new FunctionStateNode("math.sin", "Returns the trigonometric sine of an angle.", "#math.sin [num] -> [result]", (args) -> {
            if (args.size() != 1) {
                throw new IllegalArgumentException("sin takes exactly 1 argument");
            }

            if (!(args.get(0) instanceof Number number)) {
                throw new IllegalArgumentException("sin takes a number as an argument");
            }

            return Math.sin(number.doubleValue());
        }));

        root.children().add(new FunctionStateNode("math.cos", "Returns the trigonometric cosine of an angle.", "#math.cos [num] -> [result]", (args) -> {
            if (args.size() != 1) {
                throw new IllegalArgumentException("cos takes exactly 1 argument");
            }

            if (!(args.get(0) instanceof Number number)) {
                throw new IllegalArgumentException("cos takes a number as an argument");
            }

            return Math.cos(number.doubleValue());
        }));

        root.children().add(new FunctionStateNode("math.tan", "Returns the trigonometric tangent of an angle.", "#math.tan [num] -> [result]", (args) -> {
            if (args.size() != 1) {
                throw new IllegalArgumentException("tan takes exactly 1 argument");
            }

            if (!(args.get(0) instanceof Number number)) {
                throw new IllegalArgumentException("tan takes a number as an argument");
            }

            return Math.tan(number.doubleValue());
        }));

        root.children().add(new FunctionStateNode("math.asin", "Returns the trigonometric arc sine of an angle.", "#math.asin [num] -> [result]", (args) -> {
            if (args.size() != 1) {
                throw new IllegalArgumentException("asin takes exactly 1 argument");
            }

            if (!(args.get(0) instanceof Number number)) {
                throw new IllegalArgumentException("asin takes a number as an argument");
            }

            return Math.asin(number.doubleValue());
        }));

        root.children().add(new FunctionStateNode("math.acos", "Returns the trigonometric arc cosine of an angle.", "#math.acos [num] -> [result]", (args) -> {
            if (args.size() != 1) {
                throw new IllegalArgumentException("acos takes exactly 1 argument");
            }

            if (!(args.get(0) instanceof Number number)) {
                throw new IllegalArgumentException("acos takes a number as an argument");
            }

            return Math.acos(number.doubleValue());
        }));

        root.children().add(new FunctionStateNode("math.atan", "Returns the trigonometric arc tangent of an angle.", "#math.atan [num] -> [result]", (args) -> {
            if (args.size() != 1) {
                throw new IllegalArgumentException("atan takes exactly 1 argument");
            }

            if (!(args.get(0) instanceof Number number)) {
                throw new IllegalArgumentException("atan takes a number as an argument");
            }

            return Math.atan(number.doubleValue());
        }));

        root.children().add(new FunctionStateNode("math.atan2", "Returns the trigonometric arc tangent of an angle.", "#math.atan2 [num] [num] -> [result]", (args) -> {
            if (args.size() != 2) {
                throw new IllegalArgumentException("atan2 takes exactly 2 arguments");
            }

            if (!(args.get(0) instanceof Number number1)) {
                throw new IllegalArgumentException("atan2 takes a number as the first argument");
            }

            if (!(args.get(1) instanceof Number number2)) {
                throw new IllegalArgumentException("atan2 takes a number as the second argument");
            }

            return Math.atan2(number1.doubleValue(), number2.doubleValue());
        }));

        root.children().add(new FunctionStateNode("math.torads", "Converts an angle measured in degrees to an approximately equivalent angle measured in radians.", "#math.torads [num] -> [result]", (args) -> {
            if (args.size() != 1) {
                throw new IllegalArgumentException("torads takes exactly 1 argument");
            }

            if (!(args.get(0) instanceof Number number)) {
                throw new IllegalArgumentException("torads takes a number as an argument");
            }

            return Math.toRadians(number.doubleValue());
        }));
    }

    @Override
    public String description() {
        return "Provides math functions like sin, cos, tan, etc.";
    }
}
