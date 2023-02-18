package dev.syncclient.pling.docs;

import dev.syncclient.pling.cli.CLI;
import dev.syncclient.pling.cli.Flag;

import java.io.File;

public class DocsWriter {
    public static void writeDocs(DocumentationGeneratorService service) {
        String directory = CLI.flags.get(Flag.DOCS);

        if (directory == null) {
            System.out.println("No docs directory specified. Use --docs <directory> to specify a directory to write docs to.");
            return;
        }

        File file = new File(directory);

        if (!file.exists()) {
            file.mkdirs();
        }

        service.writeDocumentation(file);
    }
}
