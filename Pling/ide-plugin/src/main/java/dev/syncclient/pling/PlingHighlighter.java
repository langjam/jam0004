package dev.syncclient.pling;

import com.intellij.lexer.Lexer;
import com.intellij.openapi.editor.DefaultLanguageHighlighterColors;
import com.intellij.openapi.editor.colors.CodeInsightColors;
import com.intellij.openapi.editor.colors.TextAttributesKey;
import com.intellij.openapi.fileTypes.SyntaxHighlighterBase;
import com.intellij.psi.tree.IElementType;
import org.jetbrains.annotations.NotNull;

public class PlingHighlighter extends SyntaxHighlighterBase {
    public static final TextAttributesKey[] EMPTY_ATTR = new TextAttributesKey[0];
    public static final TextAttributesKey[] KEYWORD_ATTR = { DefaultLanguageHighlighterColors.KEYWORD };
    public static final TextAttributesKey[] IDENTIFIER_ATTR = { DefaultLanguageHighlighterColors.IDENTIFIER };
    public static final TextAttributesKey[] OPERATOR_ATTR = { DefaultLanguageHighlighterColors.OPERATION_SIGN };
    public static final TextAttributesKey[] STRING_ATTR = { DefaultLanguageHighlighterColors.STRING };
    public static final TextAttributesKey[] ERROR_ATTR = { CodeInsightColors.ERRORS_ATTRIBUTES };
    public static final TextAttributesKey[] COMMENTS_ATTR = { DefaultLanguageHighlighterColors.BLOCK_COMMENT };
    public static final TextAttributesKey[] CALL = { DefaultLanguageHighlighterColors.CONSTANT };
    public static final TextAttributesKey[] BRACKETS = { DefaultLanguageHighlighterColors.BRACKETS };
    public static final TextAttributesKey[] MODULES = { DefaultLanguageHighlighterColors.GLOBAL_VARIABLE };

    @NotNull
    @Override
    public Lexer getHighlightingLexer() {
        return new PlingLexer();
    }

    @NotNull
    @Override
    public TextAttributesKey @NotNull [] getTokenHighlights(IElementType type) {
        if (type instanceof PlingTokenType) {
            switch (((PlingTokenType) type).type) {
                case VAR:
                case FUNCTION:
                    return KEYWORD_ATTR;
                case STRING:
                    return STRING_ATTR;
                case SPACE:
                    return EMPTY_ATTR;
                case COMMENTS:
                    return COMMENTS_ATTR;
                case ERROR:
                    return ERROR_ATTR;
                case SYMBOL:
                    return IDENTIFIER_ATTR;
                case EQUAL:
                case PUNCTUATION:
                    return OPERATOR_ATTR;
                case CALL:
                    return CALL;
                case BRACKETS:
                    return BRACKETS;
                case MODULES:
                    return MODULES;
            }
        }

        throw new RuntimeException("Don't know how to highlight " + type.getClass());
    }
}
