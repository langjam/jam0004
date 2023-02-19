package dev.syncclient.pling.executor;

import dev.syncclient.pling.audio.AudioController;
import dev.syncclient.pling.executor.builtins.BasicBuiltins;
import dev.syncclient.pling.executor.builtins.HttpBuiltins;
import dev.syncclient.pling.executor.builtins.MathBuiltins;
import dev.syncclient.pling.executor.builtins.FsBuiltins;
import dev.syncclient.pling.executor.builtins.MathBuiltin;
import dev.syncclient.pling.executor.builtins.NoteBuiltins;
import dev.syncclient.pling.parser.AbstractSyntaxTree;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Stack;

public class StateTree {
    private static final StateTree instance = new StateTree();

    private final StateNode root = new StateNode(
            "std",
            "default package",
            StateNode.Type.PACKAGE,
            new ArrayList<>()
    );

    private final HashMap<String, Builtin> modules = new HashMap<>();

    private final Stack<String> currentContextPath = new Stack<>();
    private StateNode currentNode = root;
    private Interpreter interpreter;

    private StateTree() {
        new BasicBuiltins().load(root);

        modules.put("audio", new AudioController());
        modules.put("math", new MathBuiltins());
        modules.put("note", new NoteBuiltins());
        modules.put("fs", new FsBuiltins());
        modules.put("http", new HttpBuiltins());
    }

    private void reloadCurrentNode() {
        if (currentContextPath.isEmpty()) {
            currentNode = root;
            return;
        }

        currentNode = root;
        for (String context : currentContextPath) {
            assert currentNode != null;
            currentNode = currentNode.children().stream()
                    .filter(node -> node.name().equals(context))
                    .findFirst()
                    .orElse(null);
        }
    }

    private StateNode nodeForPath(Stack<String> path) {
        StateNode node = root;

        if (path.isEmpty()) {
            return node;
        }

        for (String context : path) {
            assert node != null;
            node = node.children().stream()
                    .filter(n -> n.name().equals(context))
                    .findFirst()
                    .orElse(null);
        }

        return node;
    }

    public void createContextForFunc(String name) {
        currentNode.children().add(new StateNode(name, "Function Context", StateNode.Type.FUNCTION, new ArrayList<>()));
    }

    public boolean contextExists(String name) {
        return currentNode.children().stream().anyMatch(node -> node.name().equals(name));
    }

    public void pushContext(String name) {
        currentContextPath.push(name);
        reloadCurrentNode();
    }

    public void popContext() {
        currentContextPath.pop();
        reloadCurrentNode();
    }

    public void popAndDestroy() {
        // clear the current context
        currentNode.children().clear();

        currentContextPath.pop();
        reloadCurrentNode();
    }

    public void pushVar(String name, Object value) {
        currentNode.children().add(new VarStateNode(name, "", value));
    }

    public void pushReturn(Object value) {
        if (currentNode.children().stream().noneMatch(node -> node.name().equals("__return"))) {
            pushVar("__return", value);
        } else {
            VarStateNode data = findVar("__return");
            data.setValue(value);
        }
    }

    public VarStateNode findVar(String name) {
        StateNode current = currentNode;
        Stack<String> path = new Stack<>();
        path.addAll(currentContextPath);

        while (current != null) {
            StateNode func = current.children().stream()
                    .filter(node -> node.name().equals(name))
                    .findFirst()
                    .orElse(null);

            if (func instanceof VarStateNode) {
                return (VarStateNode) func;
            }

            if (path.isEmpty()) {
                break;
            }

            path.pop();
            current = nodeForPath(path);
        }

        throw new StateException("Variable " + name + " not found");
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
        interpreter = new Interpreter(ast, this);
        interpreter.start();
    }

    public FunctionStateNode findFunc(String name) {
        // Try to find a function in the current context. If it doesn't exist, go one level up and try again.
        // If it still doesn't exist, go one level up and try again. Repeat until we reach the root.
        // If we reach the root and still don't find the function, throw an exception.
        StateNode current = currentNode;
        Stack<String> path = new Stack<>();
        path.addAll(currentContextPath);

        while (current != null) {
            StateNode func = current.children().stream()
                    .filter(node -> node.name().equals(name))
                    .findFirst()
                    .orElse(null);

            if (func instanceof FunctionStateNode) {
                return (FunctionStateNode) func;
            }

            if (path.isEmpty()) {
                break;
            }

            path.pop();
            current = nodeForPath(path);
        }

        throw new StateException("Function " + name + " not found");
    }

    public Interpreter getInterpreter() {
        return interpreter;
    }

    public boolean hasLocalVar(String var) {
        return currentNode.children().stream().anyMatch(node -> node.name().equals(var));
    }

    public LinkedList<VarStateNode> locals(StateNode source) {
        LinkedList<VarStateNode> vars = new LinkedList<>();
        for (StateNode node : source.children()) {
            if (node instanceof VarStateNode) {
                vars.add((VarStateNode) node);
            }
        }
        return vars;
    }

    public LinkedList<VarStateNode> fetchAllVariables() {
        LinkedList<VarStateNode> vars = new LinkedList<>();
        Stack<String> stack = new Stack<>();
        stack.addAll(currentContextPath);

        do {
            StateNode node = nodeForPath(stack);
            vars.addAll(locals(node));

            if (stack.isEmpty()) {
                break;
            }

            stack.pop();
        } while (!stack.isEmpty());

        return vars;
    }

    public void include(String name) {
        if (!modules.containsKey(name)) {
            throw new StateException("Module " + name + " not found");
        }

        modules.get(name).load(currentNode);
    }

    public StateNode getNode() {
        return currentNode;
    }

    public HashMap<String, Builtin> getModules() {
        return modules;
    }
}
