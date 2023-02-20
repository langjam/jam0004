package dev.syncclient.pling;

import dev.syncclient.pling.cli.CLI;
import dev.syncclient.pling.cli.Flag;
import dev.syncclient.pling.debugger.PlingDebugger;
import dev.syncclient.pling.executor.StateTree;
import dev.syncclient.pling.lexer.Lexer;
import dev.syncclient.pling.lexer.Token;
import dev.syncclient.pling.parser.AbstractSyntaxTree;
import dev.syncclient.pling.parser.Parser;

import java.io.File;
import java.util.List;
import java.util.Scanner;

public class Main {
    public static final PlingDebugger debugger = new PlingDebugger();
    public static String relPath = "";

    public static void main(final String[] args) {
        CLI.handle(args);

        StringBuilder source = new StringBuilder();
        if(args.length > 0) {
            relPath = args[0];
            File file = new File(args[0]);
            if (file.exists()) {
                try {
                    Scanner scanner = new Scanner(file);
                    while (scanner.hasNextLine())
                        source.append(scanner.nextLine()).append("\n");
                } catch (Exception e) {
                    throw new PlingException("Failed to read file: " + e.getMessage(), e);
                }
            } else exit();
        } else exit();

        Lexer lexer = new Lexer();
        List<Token.WithData> tokenList = lexer.lex(source.toString());

        debugger.ipc.tokens = tokenList;

        StateTree stateTree = StateTree.getInstance();

        Parser parser = new Parser();
        AbstractSyntaxTree ast = parser.parse(tokenList);
        debugger.ipc.ast = ast;

        if (Flag.debug) {
            try {
                debugger.ipc.run.acquire();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        stateTree.execute(ast);
    }

    private static void exit() {
        System.out.println("Syntax: pling <file>");
        System.out.println("Try 'pling --help' for more information.");
        System.exit(0);
    }
}