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

    @BuiltinExplorerInfo(name = "string.toLower", description = "Converts a string to lowercase", usage = "#string.toLower [string] -> [result]")
    public String toLower(String a) {
        return a.toLowerCase();
    }

    @BuiltinExplorerInfo(name = "string.toUpper", description = "Converts a string to uppercase", usage = "#string.toUpper [string] -> [result]")
    public String toUpper(String a) {
        return a.toUpperCase();
    }

    @BuiltinExplorerInfo(name = "string.charAt", description = "Returns the character at a given index", usage = "#string.charAt [string] [index] -> [result]")
    public char charAt(String a, int index) {
        return a.charAt(index);
    }

    @BuiltinExplorerInfo(name = "string.indexOf", description = "Returns the index of a character in a string", usage = "#string.indexOf [string] [char] -> [result]")
    public int indexOf(String a, char c) {
        return a.indexOf(c);
    }

    @BuiltinExplorerInfo(name = "string.lastIndexOf", description = "Returns the last index of a character in a string", usage = "#string.lastIndexOf [string] [char] -> [result]")
    public int lastIndexOf(String a, char c) {
        return a.lastIndexOf(c);
    }

    @BuiltinExplorerInfo(name = "string.contains", description = "Returns whether a string contains a character", usage = "#string.contains [string] [char] -> [result]")
    public boolean contains(String a, String c) {
        return a.contains(c);
    }

    @BuiltinExplorerInfo(name = "string.startsWith", description = "Returns whether a string starts with a character", usage = "#string.startsWith [string] [char] -> [result]")
    public boolean startsWith(String a, String b) {
        return a.startsWith(b);
    }

    @BuiltinExplorerInfo(name = "string.endsWith", description = "Returns whether a string ends with a character", usage = "#string.endsWith [string] [char] -> [result]")
    public boolean endsWith(String a, String b) {
        return a.endsWith(b);
    }
}
