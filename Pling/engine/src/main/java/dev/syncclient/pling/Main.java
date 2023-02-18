package dev.syncclient.pling;

import dev.syncclient.pling.audio.ALInfo;
import dev.syncclient.pling.executor.StateTree;
import dev.syncclient.pling.lexer.Lexer;
import dev.syncclient.pling.lexer.Token;
import dev.syncclient.pling.parser.AbstractSyntaxTree;
import dev.syncclient.pling.parser.Parser;
import dev.syncclient.pling.utils.StringUtils;

import java.io.File;
import java.util.List;
import java.util.Scanner;

import java.util.HashMap;

public class Main {
    public static final HashMap<Flag, String> flags = new HashMap<>();

    public static void main(final String[] args) {
        Flag currentFlag = null;

        for (final String arg : args) {
            if (arg.startsWith("--")) {
                currentFlag = Flag.getFlag(arg.substring(2));
                flags.put(currentFlag, null);
            } else if (currentFlag != null && !arg.startsWith("--")) {
                flags.put(currentFlag, arg);
                currentFlag = null;
            }
        }

        if (flags.containsKey(Flag.HELP)) {
            System.out.println("Usage: pling [file] [options]");
            System.out.println("Options:");
            System.out.println("  --help          Display this help message");
            System.out.println("  --version       Display the version of Pling");
            System.out.println("  --debug         Display debug information");
            System.out.println("  --dddd          Display inner workings of the language");
            System.out.println();
            System.out.println("~ Pling Lang by Team Sync");
            return;
        }

        if (flags.containsKey(Flag.VERSION)) {
            System.out.println("Pling Lang v0.0.1, OpenAL: ");
            ALInfo.showAlInfo();
            return;
        }

        if (flags.containsKey(Flag.VERY_DEBUG)) {
            Flag.veryDebug = true;
            System.out.println("Internal Workings Debugging Enabled");
        }

        if (flags.containsKey(Flag.DEBUG)) {
            Flag.debug = true;
            System.out.println("Debug Mode Enabled");
        }

        String fileName = args[0];

        StringBuilder source = new StringBuilder();
        File file = new File(fileName);
        if (file.exists()) {
            try {
                Scanner scanner = new Scanner(file);
                while (scanner.hasNextLine()) {
                    source.append(scanner.nextLine()).append("\n");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            System.out.println("File not found!");
            return;
        }


        Lexer lexer = new Lexer();
        List<Token.WithData> tokenList = lexer.lex(source.toString());

        if (flags.containsKey(Flag.VERY_DEBUG)) {
            System.out.println("=== BEGIN Tokens ===");
            for (Token.WithData token : tokenList) {
                System.out.println(StringUtils.ljust(token.getType().toString(), 10) + ": " + token.getValue());
            }
            System.out.println("=== STOP  Tokens ===");
        }

        StateTree stateTree = StateTree.getInstance();

        if (flags.containsKey(Flag.VERY_DEBUG)) {
            System.out.println("=== BEGIN State Tree ===");
            System.out.println(stateTree.toString());
            System.out.println("=== STOP  State Tree ===");
        }

        Parser parser = new Parser();
        AbstractSyntaxTree ast = parser.parse(tokenList);

        if (flags.containsKey(Flag.VERY_DEBUG)) {
            System.out.println("=== BEGIN AST ===");
            ast.getRoot().print(0);
            System.out.println("=== STOP  AST ===");
        }

        stateTree.execute(ast);
    }
}