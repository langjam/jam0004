package dev.syncclient.pling.docs;

import dev.syncclient.pling.executor.FunctionStateNode;
import dev.syncclient.pling.executor.StateNode;
import dev.syncclient.pling.executor.StateTree;
import dev.syncclient.pling.executor.VarStateNode;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;

/**
 * This is a static factory method that returns a single instance of the
 * {@link DocumentationGeneratorService} interface. This is a singleton
 * implementation of the {@link DocumentationGeneratorService} interface.
 *
 * @author Christian Bergschneider
 * @see DocumentationGeneratorService
 * @since 0.0.1
 */
public class SingularLazyLoadedStaticDocumentationGeneratorServiceProvider implements DocumentationGeneratorService {
    private static DocumentationGeneratorService instance;

    /**
     * This is a static factory method that returns a single instance of the
     * {@link DocumentationGeneratorService} interface. This is a singleton
     * implementation of the {@link DocumentationGeneratorService} interface.
     *
     * @return a single instance of the {@link DocumentationGeneratorService} interface.
     * @see DocumentationGeneratorService
     */
    public static DocumentationGeneratorService getInstance() {
        if (instance == null) {
            instance = new SingularLazyLoadedStaticDocumentationGeneratorServiceProvider();
        }
        return instance;
    }

    private void writeDocs(File file, StateNode node, String moduleName, String moduleDesc) {
        StringBuilder builder = new StringBuilder();

        // Write module name
        builder.append(moduleName).append("\n");
        builder.append(moduleDesc).append("\n");
        builder.append("--------\n\n");

        for (StateNode child : node.children()) {
            if (child instanceof FunctionStateNode fsn) {
                builder.append(fsn.name()).append("\n");
                builder.append(fsn.getUsage()).append("\n");
                builder.append(fsn.docs()).append("\n\n");
            } else if (child instanceof VarStateNode vsn){
                builder.append(vsn.name()).append(" = ").append(vsn.getValue()).append("\n");
                builder.append(vsn.docs()).append("\n\n");
            }
        }

        // Write to file
        if (file.exists()) {
            file.delete();
        }

        if (builder.length() <= 0) {
            return;
        }

        FileWriter writer = null;
        try {
            writer = new FileWriter(file);
            writer.write(builder.toString());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (writer != null) {
                try {
                    writer.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }


    @Override
    public void writeDocumentation(File directory) {
        // Stdlib first
        writeDocs(
                new File(directory, "internal.txt"),
                StateTree.getInstance().getNode(),
                "Builtins",
                "These are the builtins that are available in the standard library. You can use these functions without importing them."
        );

        // Then modules
        StateTree.getInstance().getModules().forEach((modName, mod) -> {
            StateNode root = new StateNode(
                    "std",
                    "default package",
                    StateNode.Type.PACKAGE,
                    new ArrayList<>()
            );
            mod.load(root);
            writeDocs(
                    new File(directory, modName + ".txt"),
                    root,
                    modName,
                    mod.description()
            );
        });
    }
}
