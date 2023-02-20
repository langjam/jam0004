package dev.syncclient.pling.actions;

import com.intellij.ide.actions.CreateFileFromTemplateAction;
import com.intellij.ide.actions.CreateFileFromTemplateDialog;
import com.intellij.openapi.fileTypes.LanguageFileType;
import com.intellij.openapi.project.Project;
import com.intellij.psi.PsiDirectory;
import dev.syncclient.pling.PlingFileType;
import org.jetbrains.annotations.NotNull;

public class PlingCreateNewFile extends CreateFileFromTemplateAction {

    public PlingCreateNewFile() {
        super("Pling", "Create new pling file", ((LanguageFileType) PlingFileType.INSTANCE).getIcon());
    }

    @Override
    protected void buildDialog(@NotNull Project project, @NotNull PsiDirectory directory, CreateFileFromTemplateDialog.Builder builder) {
        builder.setTitle("Create New Pling File");
        builder.addKind("Pling", ((LanguageFileType) PlingFileType.INSTANCE).getIcon(), "main");
    }

    @Override
    protected String getActionName(PsiDirectory directory, @NotNull String newName, String templateName) {
        return "Pling";
    }
}
