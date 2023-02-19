package dev.syncclient.pling.parser;

public class ParserException extends RuntimeException {
    public ParserException(String message, Object... args) {
        super(String.format(message, args));
    }
}
