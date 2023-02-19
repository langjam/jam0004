package dev.syncclient.pling.syntax;

import com.intellij.openapi.fileTypes.SingleLazyInstanceSyntaxHighlighterFactory;
import com.intellij.openapi.fileTypes.SyntaxHighlighter;
import dev.syncclient.pling.syntax.PlingHighlighter;
import org.jetbrains.annotations.NotNull;

public class PlingHighlighterFactory extends SingleLazyInstanceSyntaxHighlighterFactory {
    @NotNull
    @Override
    public SyntaxHighlighter createHighlighter() {
        return new PlingHighlighter();
    }
}
