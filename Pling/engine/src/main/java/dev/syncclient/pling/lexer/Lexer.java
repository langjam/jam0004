package dev.syncclient.pling.lexer;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class Lexer {
    private String source;
    private final List<Token.WithData> tokens = new ArrayList<>();
    private int current = 0;

    private char next() {
        current++;
        return source.charAt(current - 1);
    }

    private char peek() {
        if (current >= source.length()) {
            return ' ';
        }

        return source.charAt(current);
    }

    private boolean isAtEnd() {
        return current >= source.length();
    }

    private String tryEat(Function<Character, Boolean> predicate, boolean silentEOF) {
        StringBuilder builder = new StringBuilder();
        while (predicate.apply(peek())) {
            if (isAtEnd()) {
                if (silentEOF) {
                    return builder.toString();
                }
                throw new EOFException();
            }
            builder.append(next());
        }

        return builder.toString();
    }

    private String tryEat(Function<Character, Boolean> predicate) {
        return tryEat(predicate, false);
    }

    public List<Token.WithData> lex(String source) {
        this.source = source;
        tokens.clear();

        while (!isAtEnd()) {
            char c = peek();

            if (Character.isWhitespace(c)) {
                next();
            } else if (c == '=') {
                tokens.add(Token.ASSIGN.createToken(next() + ""));
            } else if (c == '#') {
                tokens.add(Token.REFERENCE.createToken(next() + ""));
            } else if (c == '[') {
                tokens.add(Token.OPEN.createToken(next() + ""));
            } else if (c == ']') {
                tokens.add(Token.CLOSE.createToken(next() + ""));
            } else if (c == ',') {
                tokens.add(Token.COMMA.createToken(next() + ""));
            } else if (c == ';') {
                tokens.add(Token.END.createToken(next() + ""));
            } else if (c == '`') {
                next();
                lastWasEscape = false;
                tokens.add(Token.STRING.createToken(tryEat(Lexer::tryEatString)));
                next();
            } else if (c == '/') {
                next();
                if (peek() == '/') {
                    next();
                    tryEat((character) -> character != '\n', true);
                } else {
                    throw new LexicalException("Unexpected character: " + c);
                }
            } else if (Character.isDigit(c)) {
                tokens.add(Token.NUMBER.createToken(tryEat(Character::isDigit)));
            } else if (Character.isAlphabetic(c)) {
                tokens.add(Token.IDENTIFIER.createToken(tryEat((character) -> Character.isAlphabetic(character) || Character.isDigit(character) || character == '.')));
            } else {
                throw new LexicalException("Unexpected character: " + c);
            }
        }

        return tokens;
    }

    private static boolean lastWasEscape = false;
    private static Boolean tryEatString(Character character) {
        if (lastWasEscape) {
            lastWasEscape = false;
            return true;
        }

        if (character == '\\') {
            lastWasEscape = true;
            return true;
        }

        return character != '`';
    }
}
