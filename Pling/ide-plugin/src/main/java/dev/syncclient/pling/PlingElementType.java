package dev.syncclient.pling;

import com.intellij.psi.tree.IElementType;
import org.jetbrains.annotations.NotNull;

public class PlingElementType extends IElementType {
    public PlingElementType(@NotNull String debugName) {
        super(debugName, PlingPlugin.INSTANCE);
    }
}