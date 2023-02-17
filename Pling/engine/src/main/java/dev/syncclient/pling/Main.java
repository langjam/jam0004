package dev.syncclient.pling;

import dev.syncclient.pling.lexer.Lexer;
import dev.syncclient.pling.lexer.Token;
import dev.syncclient.pling.utils.StringUtils;

import java.io.File;
import java.util.List;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        System.out.println("Hello world!");

        StringBuilder source = new StringBuilder();
        File file = new File("examples/test_lex.pling");
        if (file.exists()) {
            try {
                Scanner scanner = new Scanner(file);
                while (scanner.hasNextLine()) {
                    source.append(scanner.nextLine()).append("\n");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }


        Lexer lexer = new Lexer();
        List<Token.AbstractToken> tokenList = lexer.lex(source.toString());

        System.out.println("=== BEGIN Tokens ===");
        for (Token.AbstractToken token : tokenList) {
            System.out.println(StringUtils.ljust(token.getType().toString(), 10) + ": " + token.getValue());
        }
        System.out.println("=== STOP  Tokens ===");

    }
}