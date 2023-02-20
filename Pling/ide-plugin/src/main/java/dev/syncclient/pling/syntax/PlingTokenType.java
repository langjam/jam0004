package dev.syncclient.pling.syntax;

import com.intellij.psi.tree.IElementType;
import com.intellij.psi.tree.TokenSet;
import dev.syncclient.pling.PlingPlugin;

public class PlingTokenType extends IElementType {
    public enum Type {
        VAR,
        STRING,
        SPACE,
        COMMENTS,
        ERROR,
        SYMBOL,
        EQUAL,
        FUNCTION,
        CALL,
        BRACKETS,
        PUNCTUATION,
        MODULES,
        NUMBER
    }

    public static final PlingTokenType VAR = new PlingTokenType(Type.VAR);
    public static final PlingTokenType STRING = new PlingTokenType(Type.STRING);
    public static final PlingTokenType SPACE = new PlingTokenType(Type.SPACE);
    public static final PlingTokenType COMMENTS = new PlingTokenType(Type.COMMENTS);
    public static final PlingTokenType ERROR = new PlingTokenType(Type.ERROR);
    public static final PlingTokenType SYMBOL = new PlingTokenType(Type.SYMBOL);
    public static final PlingTokenType EQUAL = new PlingTokenType(Type.EQUAL);
    public static final PlingTokenType FUNCTION = new PlingTokenType(Type.FUNCTION);
    public static final PlingTokenType CALL = new PlingTokenType(Type.CALL);
    public static final PlingTokenType BRACKETS = new PlingTokenType(Type.BRACKETS);
    public static final PlingTokenType PUNCTUATION = new PlingTokenType(Type.PUNCTUATION);
    public static final PlingTokenType MODULES = new PlingTokenType(Type.MODULES);
    public static final PlingTokenType NUMBER = new PlingTokenType(Type.NUMBER);

    public static final TokenSet WHITE_SPACE_TYPES = TokenSet.create(SPACE);
    public static final TokenSet COMMENT_TYPES = TokenSet.create(COMMENTS);
    public static final TokenSet STRING_TYPES = TokenSet.create(STRING);

    public final Type type;

    private PlingTokenType(Type type) {
        super(type.toString(), PlingPlugin.INSTANCE);

        this.type = type;
    }
}
