package dev.syncclient.pling.executor;

import dev.syncclient.pling.parser.AbstractSyntaxTree;

import java.util.ArrayList;

public class Interpreter {
    private final AbstractSyntaxTree ast;
    private final StateTree stateTree;

    public Interpreter(AbstractSyntaxTree ast, StateTree stateTree) {
        this.ast = ast;
        this.stateTree = stateTree;
    }

    public void start() {
        exec(ast.getRoot());
    }

    private Object exec(AbstractSyntaxTree.Node node) {
        if (node instanceof AbstractSyntaxTree.StatementsNode) {
            for (AbstractSyntaxTree.Node child : node.getChildren()) {
                exec(child);
            }
        } else if (node instanceof AbstractSyntaxTree.Statement.CallNode callNode) {
            return call(callNode);
        } else if (node instanceof AbstractSyntaxTree.Literal.NumberNode) {
            return ((AbstractSyntaxTree.Literal.NumberNode) node).getValue();
        } else if (node instanceof AbstractSyntaxTree.Literal.StringNode) {
            return ((AbstractSyntaxTree.Literal.StringNode) node).getValue();
        } else if (node instanceof AbstractSyntaxTree.Statement.VarDefNode varDefNode) {
            return varDef(varDefNode);
        } else if (node instanceof AbstractSyntaxTree.Statement.VarSetNode varSetNode) {
            return varSet(varSetNode);
        } else if (node instanceof AbstractSyntaxTree.Literal.VariableNode varNode) {
            return stateTree.findVar(varNode.getName()).getValue();
        } else {
            throw new RuntimeException("Unknown node: " + node);
        }

        return null;
    }

    private Object call(AbstractSyntaxTree.Statement.CallNode callNode) {
        ArrayList<Object> args = new ArrayList<>();

        for (AbstractSyntaxTree.Node arg : callNode.getArgs()) {
            args.add(exec(arg));
        }

        return stateTree.findFunc(callNode.getName()).getFunction().apply(args);
    }


    private Object varDef(AbstractSyntaxTree.Statement.VarDefNode node) {
        stateTree.pushVar(node.getName(), exec(node.getValue()));
        return null;
    }

    private Object varSet(AbstractSyntaxTree.Statement.VarSetNode node) {
        stateTree.findVar(node.getName()).setValue(exec(node.getValue()));
        return null;
    }
}
