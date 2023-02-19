package dev.syncclient.pling;

import com.intellij.lang.Language;
import org.jetbrains.annotations.NotNull;

public class PlingPlugin extends Language {
    public static final PlingPlugin INSTANCE = new PlingPlugin();

    private PlingPlugin() {
        super("Pling");
    }

    @Override
    public @NotNull String getDisplayName() {
        return "Pling";
    }

    @Override
    public boolean isCaseSensitive() {
        return true;
    }
}
