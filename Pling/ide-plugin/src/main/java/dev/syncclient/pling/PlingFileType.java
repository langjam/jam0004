package dev.syncclient.pling;

import com.intellij.openapi.fileTypes.LanguageFileType;
import com.intellij.openapi.util.IconLoader;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;

public class PlingFileType extends LanguageFileType {
    public static final PlingFileType INSTANCE = new PlingFileType();

    private PlingFileType() {
        super(PlingPlugin.INSTANCE);
    }

    @NotNull
    @Override
    public String getName() {
        return "Pling File";
    }

    @NotNull
    @Override
    public String getDescription() {
        return "";
    }

    @NotNull
    @Override
    public String getDefaultExtension() {
        return "pling";
    }

    @Nullable
    @Override
    public Icon getIcon() {
        return IconLoader.getIcon("/icons/pling-16x.png", PlingFileType.class);
    }
}
