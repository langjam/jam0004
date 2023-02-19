package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.executor.BuiltinExplorer;

public class StringBuiltins extends BuiltinExplorer {
    @Override
    public String description() {
        return "Provides functions for working with strings.";
    }

    @BuiltinExplorerInfo(name = "string.concat", description = "Concatenates 2 strings", usage = "#string.concat [string] [string] -> [result]")
    public String concat(String a, String b) {
        return a + b;
    }

    @BuiltinExplorerInfo(name = "string.length", description = "Returns the length of a string", usage = "#string.length [string] -> [result]")
    public int length(String a) {
        return a.length();
    }

    @BuiltinExplorerInfo(name = "string.substring", description = "Returns a substring of a string", usage = "#string.substring [string] [start] [end] -> [result]")
    public String substring(String a, int start, int end) {
        return a.substring(start, end);
    }

    @BuiltinExplorerInfo(name = "string.replace", description = "Replaces a substring of a string", usage = "#string.replace [string] [start] [end] [replacement] -> [result]")
    public String replace(String a, int start, int end, String replacement) {
        return a.substring(0, start) + replacement + a.substring(end);
    }

    @BuiltinExplorerInfo(name = "string.trim", description = "Trims a string", usage = "#string.trim [string] -> [result]")
    public String trim(String a) {
        return a.trim();
    }

    @BuiltinExplorerInfo(name = "string.lower", description = "Converts a string to lowercase", usage = "#string.lower [string] -> [result]")
    public String toLower(String a) {
        return a.toLowerCase();
    }

    @BuiltinExplorerInfo(name = "string.upper", description = "Converts a string to uppercase", usage = "#string.upper [string] -> [result]")
    public String toUpper(String a) {
        return a.toUpperCase();
    }

    @BuiltinExplorerInfo(name = "string.charat", description = "Returns the character at a given index", usage = "#string.charat [string] [index] -> [result]")
    public char charAt(String a, int index) {
        return a.charAt(index);
    }

    @BuiltinExplorerInfo(name = "string.index", description = "Returns the index of a character in a string", usage = "#string.index [string] [char] -> [result]")
    public int indexOf(String a, char c) {
        return a.indexOf(c);
    }

    @BuiltinExplorerInfo(name = "string.lastindex", description = "Returns the last index of a character in a string", usage = "#string.lastindex [string] [char] -> [result]")
    public int lastIndexOf(String a, char c) {
        return a.lastIndexOf(c);
    }

    @BuiltinExplorerInfo(name = "string.contains", description = "Returns whether a string contains a character", usage = "#string.contains [string] [char] -> [result]")
    public boolean contains(String a, String c) {
        return a.contains(c);
    }

    @BuiltinExplorerInfo(name = "string.startswith", description = "Returns whether a string starts with a character", usage = "#string.startswith [string] [char] -> [result]")
    public boolean startsWith(String a, String b) {
        return a.startsWith(b);
    }

    @BuiltinExplorerInfo(name = "string.endswith", description = "Returns whether a string ends with a character", usage = "#string.endswith [string] [char] -> [result]")
    public boolean endsWith(String a, String b) {
        return a.endsWith(b);
    }

    @BuiltinExplorerInfo(name = "string.matches", description = "Returns whether a string matches a regex", usage = "#string.matches [string] [regex] -> [result]")
    public boolean matches(String a, String b) {
        return a.matches(b);
    }

    @BuiltinExplorerInfo(name = "string.split", description = "Splits a string by a regex", usage = "#string.split [string] [regex] [matchNum] -> [result]")
    public String split(String a, String b, int num) {
        return a.split(b)[num];
    }
}
