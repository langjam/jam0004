package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.executor.BuiltinExplorer;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class IoBuiltins extends BuiltinExplorer {
    public static final String RESET = "\033[0m";  // Text Reset
    @Override
    public String description() {
        return "Provides functions and utilities for IO operations";
    }

    @BuiltinExplorerInfo(name = "io.readln", description = "Reads a line from the console", usage = "#io.readln -> [line]")
    public String readln() {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        try {
            return reader.readLine();
        } catch (Exception e) {
            return null;
        }
    }

    @BuiltinExplorerInfo(name = "io.parsenum", description = "Parses a number from a string", usage = "#io.parseNum [string] -> [number]")
    public double parseNum(String str) {
        return Double.parseDouble(str);
    }

    @BuiltinExplorerInfo(name = "io.printcolor",
            description = "Prints a string with a color [BLACK, RED, GREEN, YELLOW, BLUE, PURPLE, CYAN, WHITE]",
            usage = "#io.printcolor [color] [string]")
    public void printcolor(String color, String str) {
        System.out.print(Color.valueOf(color.toUpperCase()).getColor() + str + RESET);
    }

    public enum Color {
        BLACK("\033[0;30m"),
        RED("\033[0;31m"),
        GREEN("\033[0;32m"),
        YELLOW("\033[0;33m"),
        BLUE("\033[0;34m"),
        PURPLE("\033[0;35m"),
        CYAN("\033[0;36m"),
        WHITE("\033[0;37m");

        private final String color;

        Color(String color) {
            this.color = color;
        }

        public String getColor() {
            return color;
        }
    }
}
