package dev.syncclient.pling.parser;

import java.util.ArrayList;
import java.util.List;

public class AST {
    public List<ClassNode> classes = new ArrayList<>();

    public enum Type {
        CLASS,
        FUNCTION,
        VARIABLE,
        STATEMENT
    }

    public void add(String value, Type type, String... args) {
        if (classes.size() == 0) {
            ClassNode clazz = new ClassNode();
            clazz.name = "Class" + (int) (Math.random() * 100000);
            classes.add(clazz);
        }

        switch (type) {
            case CLASS -> {
                ClassNode clazz = new ClassNode();
                clazz.name = value;
                classes.add(clazz);
            }
            case FUNCTION -> {
                FunctionNode function = new FunctionNode();
                function.name = value;

                for (String arg : args) {
                    function.arguments.add(new ArgumentNode(arg));
                }

                classes.get(classes.size() - 1).functions.add(function);
            }
            case VARIABLE -> {

            }
            case STATEMENT -> {

            }
        }
    }

    public static class Node {
        public Object name;
        public Object value;
        public List<Node> children = new ArrayList<>();
    }

    public static class ClassNode extends Node {
        public Object name;
        public List<FunctionNode> functions = new ArrayList<>();
    }

    public static class FunctionNode extends Node {
        public Object name;
        public List<VariableNode> variables = new ArrayList<>();
        public List<StatementNode> statements = new ArrayList<>();
        public List<ArgumentNode> arguments = new ArrayList<>();
    }

    public static class ArgumentNode extends Node {
        public Object name;

        public ArgumentNode(String name) {
            this.name = name;
        }
    }

    public static class VariableNode extends Node {
        public Object name;
        public Object value;

        public VariableNode(String name, String value) {
            this.name = name;
            this.value = value;
        }
    }

    public static class StatementNode extends Node {
        public Object name;

        public StatementNode(String name) {
            this.name = name;
        }
    }
}
