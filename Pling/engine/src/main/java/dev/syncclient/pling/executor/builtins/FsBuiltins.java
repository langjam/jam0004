package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.Main;
import dev.syncclient.pling.PlingException;
import dev.syncclient.pling.executor.BuiltinExplorer;

import java.io.File;
import java.util.Objects;
import java.util.Scanner;

public class FsBuiltins extends BuiltinExplorer {

    private File getFileFromPath(String path) {
        if (path.startsWith(";")) {
            File scriptFile = new File(Main.relPath);
            path = scriptFile.getParent() + "/" + path.substring(1);
        }

        return new File(path);
    }

    @BuiltinExplorerInfo(name = "fs.read", description = "Reads a file (Paths starting with ; are relative to the parsed file)", usage = "#fs.read [file] -> [contents]")
    public Object readFile(String path) {
        File file = getFileFromPath(path);
        if (!file.exists()) {
            return -1;
        }

        StringBuilder source = new StringBuilder();
        try {
            Scanner scanner = new Scanner(file);
            while (scanner.hasNextLine())
                source.append(scanner.nextLine()).append("\n");
        } catch (Exception e) {
            throw new PlingException("Failed to read file: " + e.getMessage(), e);
        }

        return source.toString();
    }

    @BuiltinExplorerInfo(name = "fs.write", description = "Writes a file (Paths starting with ; are relative to the parsed file)", usage = "#fs.write [file] [contents] -> [1/0]")
    public Object writeFile(String path, String contents) {
        File file = getFileFromPath(path);
        if (!file.exists()) {
            return -1;
        }

        try {
            file.createNewFile();
        } catch (Exception e) {
            throw new PlingException("Failed to write file: " + e.getMessage(), e);
        }

        return 1;
    }

    @BuiltinExplorerInfo(name = "fs.exists", description = "Checks if a file exists (Paths starting with ; are relative to the parsed file)", usage = "#fs.exists [file] -> [1/0]")
    public Object fileExists(String path) {
        File file = getFileFromPath(path);
        return file.exists() ? 1 : 0;
    }

    @BuiltinExplorerInfo(name = "fs.mkdir", description = "Creates a directory (Paths starting with ; are relative to the parsed file)", usage = "#fs.mkdir [dir] -> [1/0]")
    public Object mkdir(String path) {
        File file = getFileFromPath(path);
        if (file.exists()) {
            return -1;
        }

        try {
            file.mkdirs();
        } catch (Exception e) {
            throw new PlingException("Failed to create directory: " + e.getMessage(), e);
        }

        return 1;
    }

    @BuiltinExplorerInfo(name = "fs.rmdir", description = "Removes a directory (Paths starting with ; are relative to the parsed file)", usage = "#fs.rmdir [dir] -> [1/0]")
    public Object rmdir(String path) {
        File file = getFileFromPath(path);
        if (!file.exists()) {
            return -1;
        }

        try {
            // recursively delete the directory
            for (File f : Objects.requireNonNull(file.listFiles())) {
                if (f.isDirectory()) {
                    rmdir(f.getAbsolutePath());
                } else {
                    f.delete();
                }
            }

        } catch (Exception e) {
            throw new PlingException("Failed to remove directory: " + e.getMessage(), e);
        }

        return 1;
    }

    @Override
    public String description() {
        return "Filesystem utilities";
    }
}
