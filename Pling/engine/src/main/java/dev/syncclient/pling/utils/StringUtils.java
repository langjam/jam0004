package dev.syncclient.pling.utils;

public class StringUtils {
    public static String ljust(String s, int n) {
        return String.format("%1$-" + n + "s", s);
    }
}
