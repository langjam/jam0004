package dev.syncclient.pling.executor;

import dev.syncclient.pling.executor.builtins.BasicBuiltins;
import dev.syncclient.pling.parser.AbstractSyntaxTree;

import java.util.ArrayList;
import java.util.Stack;
import java.util.function.Function;

public class StateTree {
    private static final StateTree instance = new StateTree();

    private final StateNode root = new StateNode(
            "std",
            "default package",
            StateNode.Type.PACKAGE,
            new ArrayList<>()
    );

    private final Stack<String> currentContextPath = new Stack<>();
    private StateNode currentNode = root;

    private StateTree() {
        new BasicBuiltins().load(root);
    }

    private void reloadCurrentNode() {
        if (currentContextPath.isEmpty()) {
            currentNode = root;
            return;
        }

        currentNode = root;
        for (String context : currentContextPath) {
            currentNode = currentNode.children().stream()
                    .filter(node -> node.name().equals(context))
                    .findFirst()
                    .orElseThrow();
        }
    }

    public void pushContext(String name) {
        currentContextPath.push(name);
        reloadCurrentNode();
    }

    public void popContext() {
        currentContextPath.pop();
        reloadCurrentNode();
    }

    public StateNode findName(String name) {
        // TODO: implement
        return currentNode.children().stream()
                .filter(node -> node.name().equals(name))
                .findFirst()
                .orElse(null);
    }

    public static StateTree getInstance() {
        return instance;
    }

    @Override
    public String toString() {
        return "StateTree{" +
                "root=" + root +
                ", currentContextPath=" + currentContextPath +
                ", currentNode=" + currentNode +
                '}';
    }

    public void execute(AbstractSyntaxTree ast) {
        Interpreter interpreter = new Interpreter(ast, this);
        interpreter.start();
    }

    public FunctionStateNode findFunc(String name) {
        return (FunctionStateNode) currentNode.children().stream()
                .filter(node -> node.name().equals(name))
                .findFirst()
                .orElse(null);
    }
}
