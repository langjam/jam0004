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

    public void pushVar(String name, Object value) {
        currentNode.children().add(new VarStateNode(name, "", value));
    }

    public VarStateNode findVar(String name) {
        VarStateNode data = (VarStateNode) currentNode.children().stream()
                .filter(node -> node.name().equals(name))
                .findFirst()
                .orElse(null);

        if (data == null) {
            throw new StateException("Variable " + name + " not found");
        }

        return data;
    }

    public void pushFunc(String name, AbstractSyntaxTree.FuncDefNode func) {
        currentNode.children().add(new FunctionStateNode(name, "Function from code", func::run));
    }

    public static StateTree getInstance() {
        return instance;
    }

    public static String indent(int level, String srcWithLineBreaks) {
        String[] lines = srcWithLineBreaks.split("\r\n|\r|\n");

        StringBuilder sb = new StringBuilder();
        for (String line : lines) {
            sb.append("    ".repeat(Math.max(0, level)));
            sb.append(line).append("\n");
        }

        return sb.toString();
    }

    @Override
    public String toString() {
        return "StateTree{\n" +
                "    root=\n" + indent(2, root.toString()) +
                "    currentContextPath=" + currentContextPath +
                "\n    currentNode=" + currentNode.name() + "(" + currentNode.type() + ")\n" +
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
