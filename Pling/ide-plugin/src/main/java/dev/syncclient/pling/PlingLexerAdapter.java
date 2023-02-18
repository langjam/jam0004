package dev.syncclient.pling;

import com.intellij.lexer.FlexAdapter;

public class PlingLexerAdapter extends FlexAdapter {
    public PlingLexerAdapter() {
        super(new PlingLexer());
    }
}
