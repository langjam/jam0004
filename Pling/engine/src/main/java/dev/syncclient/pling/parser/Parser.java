package dev.syncclient.pling.parser;

import dev.syncclient.pling.Flag;
import dev.syncclient.pling.lexer.Token;

import java.util.LinkedList;
import java.util.List;

public class Parser {
    private LinkedList<Token.WithData> tokens;
    private AbstractSyntaxTree ast;

    public AbstractSyntaxTree parse(List<Token.WithData> _tokens) {
        this.tokens = new LinkedList<>(_tokens);
        this.ast = new AbstractSyntaxTree();

        ast.setRoot(stmts(tokens));

        return ast;
    }

    private void checkFormat(LinkedList<Token.WithData> tokens, Token... expected) {
        tokens = new LinkedList<>(tokens);
        for (int i = 0; i < expected.length; i++) {
            Token token = expected[i];
            if (tokens.isEmpty()) {
                throw new RuntimeException("Unexpected end of statement");
            }
            Token.WithData current = tokens.pop();

            if (token == Token.ANY) {
                continue;
            }

            if (token == Token.ANY_ANYNUM) {
                // skip any number of tokens until we find the next expected token
                while (current.getType() != expected[i + 1]) {
                    if (tokens.isEmpty()) {
                        throw new RuntimeException("Unexpected end of statement");
                    }
                    current = tokens.pop();
                }

                i++;
                continue;
            }

            if (current.getType() != token) {
                throw new RuntimeException("Unexpected token: " + current);
            }
        }
    }


    // Parse a block of code
    private AbstractSyntaxTree.Node stmts(LinkedList<Token.WithData> tokens) {
        LinkedList<Token.WithData> currentStmt = new LinkedList<>();
        AbstractSyntaxTree.StatementsNode statementsNode = new AbstractSyntaxTree.StatementsNode();

        while (!tokens.isEmpty()) {
            Token.WithData token = tokens.pop();
            if (token.getType() == Token.OPEN) {
                // Start of a block of code
                LinkedList<Token.WithData> blockTokens = new LinkedList<>();

                int depth = 0;
                while (true) {
                    if (token.getType() == Token.OPEN) {
                        depth++;
                    } else if (token.getType() == Token.CLOSE) {
                        depth--;
                    }

                    if (depth == 0) {
                        break;
                    }

                    blockTokens.add(token);

                    if (tokens.isEmpty()) {
                        throw new ParserException("Unexpected end of file while parsing block");
                    }

                    token = tokens.pop();
                }

                Token.WithData blockToken = new Token.BlockData(blockTokens);
                currentStmt.add(blockToken);
                token = Token.END.createToken(";");
            }
            if (token.getType() == Token.END) {
                AbstractSyntaxTree.Node node = stmt(currentStmt);
                if (node != null) {
                    statementsNode.addChild(node);
                }
                currentStmt.clear();
            } else {
                currentStmt.add(token);
            }
        }

        return statementsNode;
    }

    private AbstractSyntaxTree.Node stmt(LinkedList<Token.WithData> currentStmt) {
        if (currentStmt.isEmpty()) {
            return null;
        }


        Token.WithData first = currentStmt.peek();
        assert first != null;
        if (first.getType() == Token.IDENTIFIER) {
            // This should be a keyword or a variable

            if (first.getValue().equals(Keywords.VARDEF.getKw())) {
                // This is a variable definition
                return vardef(currentStmt);
            } else if (first.getValue().equals(Keywords.FUNCDEF.getKw())) {
                // This is a function definition
                return funcdef(currentStmt);
            } else if (currentStmt.size() > 2 && currentStmt.get(1).getType() == Token.ASSIGN) {
                // This is a variable set
                return varset(currentStmt);
            } else {
                // This is a variable
                return new AbstractSyntaxTree.Literal.VariableNode(first.getValue());
            }
        } else if (first.getType() == Token.NUMBER) {
            // This is just a number
            return new AbstractSyntaxTree.Literal.NumberNode(Double.parseDouble(first.getValue()));
        } else if (first.getType() == Token.STRING) {
            // This is just a string
            return new AbstractSyntaxTree.Literal.StringNode(first.getValue());
        } else if (first.getType() == Token.REFERENCE) {
            return callAny(currentStmt);
        } else {
            throw new ParserException("Unexpected token: " + first);
        }
    }

    private AbstractSyntaxTree.Node funcdef(LinkedList<Token.WithData> currentStmt) {
        // Check Format
        checkFormat(currentStmt, Token.IDENTIFIER, Token.IDENTIFIER, Token.ANY_ANYNUM, Token.BLOCK);

        currentStmt.pop(); // Remove "fun"
        String funcName = currentStmt.pop().getValue();

        LinkedList<AbstractSyntaxTree.Node> args = new LinkedList<>();

        Token.WithData token = currentStmt.pop();
        while (token.getType() != Token.BLOCK) {
            if (token.getType() != Token.REFERENCE) {
                throw new ParserException("Unexpected token: " + token);
            }

            token = currentStmt.pop();

            args.add(stmt(new LinkedList<>(List.of(token))));
            token = currentStmt.pop();
        }

        LinkedList<Token.WithData> block = ((Token.BlockData) token).getData();

        return new AbstractSyntaxTree.FuncDefNode(funcName, args, stmts(new LinkedList<>(block.subList(1, block.size() - 1))));
    }

    private AbstractSyntaxTree.Node vardef(LinkedList<Token.WithData> currentStmt) {
        // Check Format
        checkFormat(currentStmt, Token.IDENTIFIER, Token.IDENTIFIER, Token.ASSIGN, Token.ANY);

        String varName = currentStmt.get(1).getValue();
        LinkedList<Token.WithData> value = new LinkedList<>(currentStmt.subList(3, currentStmt.size()));

        return new AbstractSyntaxTree.Statement.VarDefNode(varName, stmt(value));
    }

    private AbstractSyntaxTree.Node varset(LinkedList<Token.WithData> currentStmt) {
        // Check Format
        checkFormat(currentStmt, Token.IDENTIFIER, Token.ASSIGN, Token.ANY);

        String varName = currentStmt.get(0).getValue();
        LinkedList<Token.WithData> value = new LinkedList<>(currentStmt.subList(2, currentStmt.size()));

        return new AbstractSyntaxTree.Statement.VarSetNode(varName, stmt(value));
    }

    private AbstractSyntaxTree.Node callAny(LinkedList<Token.WithData> currentStmt) {
        // Check Format
        checkFormat(currentStmt, Token.REFERENCE, Token.IDENTIFIER);
        currentStmt.pop();
        String callName = currentStmt.pop().getValue();

        List<AbstractSyntaxTree.Node> args = new LinkedList<>();
        List<Token.WithData> currentArg = new LinkedList<>();
        while (!currentStmt.isEmpty()) {
            Token.WithData token = currentStmt.pop();
            if (token.getType() == Token.COMMA) {
                args.add(stmt(new LinkedList<>(currentArg)));
                currentArg.clear();
            } else {
                currentArg.add(token);
            }
        }

        if (!currentArg.isEmpty()) {
            args.add(stmt(new LinkedList<>(currentArg)));
        }

        return new AbstractSyntaxTree.Statement.CallNode(callName, args);
    }

    public enum Keywords {
        VARDEF("var"),
        FUNCDEF("fun");

        private final String kw;

        Keywords(String kw) {
            this.kw = kw;
        }

        public String getKw() {
            return kw;
        }
    }
}
