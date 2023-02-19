package dev.syncclient.pling.executor.builtins;

import dev.syncclient.pling.executor.BuiltinExplorer;

import java.io.IOException;

public class OSBuiltins extends BuiltinExplorer {
    @Override
    public String description() {
        return "Provides access to the operating system and runtime environment";
    }

    @BuiltinExplorerInfo(name = "os.getname", description = "Returns the name of the operating system", usage = "#os.getname -> [result]")
    public String os() {
        return System.getProperty("os.name");
    }

    @BuiltinExplorerInfo(name = "os.getarch", description = "Returns the architecture of the operating system", usage = "#os.getarch -> [result]")
    public String arch() {
        return System.getProperty("os.arch");
    }

    @BuiltinExplorerInfo(name = "os.getversion", description = "Returns the version of the operating system", usage = "#os.getversion -> [result]")
    public String version() {
        return System.getProperty("os.version");
    }

    @BuiltinExplorerInfo(name = "os.getjavaversion", description = "Returns the version of the Java runtime environment", usage = "#os.getjavaversion -> [result]")
    public String javaVersion() {
        return System.getProperty("java.version");
    }

    @BuiltinExplorerInfo(name = "os.runtime.free", description = "Returns the amount of free memory in the Java Virtual Machine", usage = "#os.runtime.free -> [result]")
    public double freeMemory() {
        return Runtime.getRuntime().freeMemory();
    }

    @BuiltinExplorerInfo(name = "os.runtime.max", description = "Returns the maximum amount of memory that the Java virtual machine will attempt to use", usage = "#os.runtime.max -> [result]")
    public double maxMemory() {
        return Runtime.getRuntime().maxMemory();
    }

    @BuiltinExplorerInfo(name = "os.runtime.total", description = "Returns the total amount of memory in the Java virtual machine", usage = "#os.runtime.total -> [result]")
    public double totalMemory() {
        return Runtime.getRuntime().totalMemory();
    }

    @BuiltinExplorerInfo(name = "os.runtime.available", description = "Returns the maximum amount of memory that the Java virtual machine will attempt to use", usage = "#os.runtime.available -> [result]")
    public double availableProcessors() {
        return Runtime.getRuntime().availableProcessors();
    }

    @BuiltinExplorerInfo(name = "os.runtime.gc", description = "Runs the garbage collector", usage = "#os.runtime.gc -> [result]")
    public void gc() {
        Runtime.getRuntime().gc();
    }

    @BuiltinExplorerInfo(name = "os.runtime.exit", description = "Terminates the currently running Java virtual machine", usage = "#os.runtime.exit -> [result]")
    public void exit() {
        Runtime.getRuntime().exit(0);
    }

    @BuiltinExplorerInfo(name = "os.runtime.exec", description = "Executes the specified string command in a separate process", usage = "#os.runtime.exec [command] -> [result]")
    public void exec(String command) throws IOException {
        Runtime.getRuntime().exec(command);
    }

    @BuiltinExplorerInfo(name = "os.runtime.exec", description = "Executes the specified string command in a separate process", usage = "#os.runtime.exec [command] [envp] -> [result]")
    public void exec(String command, String[] envp) throws IOException {
        Runtime.getRuntime().exec(command, envp);
    }
}
