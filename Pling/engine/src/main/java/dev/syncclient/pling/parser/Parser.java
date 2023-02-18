package dev.syncclient.pling.parser;

import dev.syncclient.pling.lexer.Token;

import java.util.LinkedList;
import java.util.List;
import java.util.Objects;

public class Parser {
    LinkedList<Token.AbstractToken> tokens;
    Token nextToken;

    private final AST ast = new AST();

    public void parse(List<Token.AbstractToken> tokens) {
        this.tokens = new LinkedList<>(tokens);
        nextToken = this.tokens.getFirst().getType();

        parseIdentifier();
    }

    private void parseIdentifier() {
        switch (this.tokens.get(0).getType()){
            case IDENTIFIER -> {
                switch (this.tokens.get(0).getValue()){
                    case "cls" -> {
                        System.out.println("Class: " + this.tokens.get(1).getValue());
                    }
                    case "fun" -> {
                        nextToken();

                        String functionName = this.tokens.get(0).getValue();

                        while(this.nextToken != Token.CLOSE){
                            nextToken();

                            switch (this.nextToken){
                                case REFERENCE -> {
                                    nextToken();

                                    List<String> parameters = new LinkedList<>();

                                    while(this.nextToken != Token.OPEN){
                                        if(this.tokens.get(0).getType() == Token.REFERENCE)
                                            nextToken();

                                        parameters.add(this.tokens.get(0).getValue());
                                        nextToken();
                                    }

                                    ast.add(functionName, AST.Type.FUNCTION, parameters.toArray(new String[0]));
                                }
                                case IDENTIFIER -> {
                                    switch (this.tokens.get(0).getValue()){
                                        case "print" -> {
                                            nextToken();

                                            List<String> parameters = new LinkedList<>();

                                            while(this.nextToken != Token.END){
                                                if(Objects.equals(this.tokens.get(0).getValue(), ","))
                                                    nextToken();

                                                parameters.add(this.tokens.get(0).getValue());
                                                nextToken();
                                            }

                                            System.out.println("  Print: " + String.join(", ", parameters));
                                        }
                                        case "ret" -> {

                                        }
                                        default -> {

                                        }
                                    }
                                }
                                default -> {

                                }
                            }
                        }
                    }
                    case "var" -> {
                        System.out.println("Variable: " + this.tokens.get(1).getValue());
                    }
                }
            }
            case COMMENT -> {
                System.out.println("Comment: " + this.tokens.get(0).getValue());
            }
        }

        System.out.println("---AST---");

        ast.classes.forEach(clazz -> {
            System.out.println(clazz.name);
            clazz.functions.forEach(function -> {
                System.out.println("  FUNC: " + function.name);
                function.arguments.forEach(argument -> {
                    System.out.println("    ARG: " + argument.name);
                });
            });
        });
    }

    private void nextToken() {
        tokens.pop();

        if (tokens.isEmpty())
            nextToken = Token.END;
        else
            nextToken = tokens.getFirst().getType();
    }
}
