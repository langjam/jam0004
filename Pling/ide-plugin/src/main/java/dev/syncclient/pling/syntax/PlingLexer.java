package dev.syncclient.pling.syntax;

import com.intellij.lexer.LexerBase;
import com.intellij.psi.tree.IElementType;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class PlingLexer extends LexerBase {
    private CharSequence buffer;
    private int bufferEnd, firstTokenStart, firstTokenEnd;
    private PlingTokenType firstToken;

    public static final Pattern VAR = Pattern.compile("var\\b|ret\\b|use\\b");
    public static final Pattern STRING = Pattern.compile("`[^`]+`");
    public static final Pattern SYMBOL = Pattern.compile("\\w+");
    public static final Pattern EQUAL = Pattern.compile("=");
    public static final Pattern SPACE = Pattern.compile("\\s+");
    public static final Pattern COMMENTS = Pattern.compile("//.*");
    public static final Pattern FUNCTION = Pattern.compile("fun\\b|if\\b|eif\\b|else\\b|while\\b");
    public static final Pattern CALL = Pattern.compile("#[^\\s.]+");
    public static final Pattern BRACKETS = Pattern.compile("[\\[\\]]");
    public static final Pattern PUNCTUATION = Pattern.compile("[,;]");
    public static final Pattern MODULES = Pattern.compile("audio\\b");
    public static final Pattern NUMBER = Pattern.compile("[\\d.]+");

    private boolean tryMatch(Pattern pattern) {
        Matcher matcher = pattern.matcher(buffer).region(firstTokenEnd, bufferEnd);

        if (matcher.lookingAt()) {
            MatchResult result = matcher.toMatchResult();

            firstTokenStart = result.start();
            firstTokenEnd = result.end();

            return true;
        }
        else
            return false;
    }

    @Override
    public void advance() {
        if (firstTokenEnd == bufferEnd)
            firstToken = null;
        else if (tryMatch(NUMBER))
            firstToken = PlingTokenType.NUMBER;
        else if (tryMatch(VAR))
            firstToken = PlingTokenType.VAR;
        else if (tryMatch(FUNCTION))
            firstToken = PlingTokenType.FUNCTION;
        else if (tryMatch(CALL))
            firstToken = PlingTokenType.CALL;
        else if (tryMatch(STRING))
            firstToken = PlingTokenType.STRING;
        else if (tryMatch(PUNCTUATION))
            firstToken = PlingTokenType.PUNCTUATION;
        else if (tryMatch(SYMBOL))
            firstToken = PlingTokenType.SYMBOL;
        else if (tryMatch(MODULES))
            firstToken = PlingTokenType.MODULES;
        else if (tryMatch(EQUAL))
            firstToken = PlingTokenType.EQUAL;
        else if (tryMatch(SPACE))
            firstToken = PlingTokenType.SPACE;
        else if (tryMatch(COMMENTS))
            firstToken = PlingTokenType.COMMENTS;
        else if (tryMatch(BRACKETS))
            firstToken = PlingTokenType.BRACKETS;
        else {
            firstTokenStart = firstTokenEnd;
            firstTokenEnd = firstTokenEnd + 1;
            firstToken = PlingTokenType.ERROR;
        }
    }

    @Override
    public void start(@NotNull CharSequence buffer, int startOffset, int endOffset, int initialState) {
        this.buffer = buffer;
        this.firstTokenStart = startOffset;
        this.firstTokenEnd = startOffset;
        this.bufferEnd = endOffset;

        advance();
    }

    @Override
    public int getState() {
        return 0;
    }

    @Nullable
    @Override
    public IElementType getTokenType() {
        return firstToken;
    }

    @Override
    public int getTokenStart() {
        return firstTokenStart;
    }

    @Override
    public int getTokenEnd() {
        return firstTokenEnd;
    }

    @NotNull
    @Override
    public CharSequence getBufferSequence() {
        return buffer;
    }

    @Override
    public int getBufferEnd() {
        return bufferEnd;
    }
}
