package dev.syncclient.pling.parser;

import java.util.ArrayList;
import java.util.List;

public class AbstractSyntaxTree {

    private Node root;

    public AbstractSyntaxTree() {
        this.root = new StatementsNode();
    }

    public Node getRoot() {
        return root;
    }

    public void setRoot(Node stmts) {
        this.root = stmts;
    }


    public static class Node {
        private final List<Node> children;

        public Node() {
            this.children = new ArrayList<>();
        }
        public List<Node> getChildren() {
            return children;
        }

        public void addChild(Node child) {
            children.add(child);
        }

        public void addChildren(List<Node> children) {
            this.children.addAll(children);
        }

        public void print(int indent) {
            for (int i = 0; i < indent; i++) {
                System.out.print(" ");
            }
            System.out.println(this);
            for (Node child : children) {
                child.print(indent + 2);
            }
        }

        @Override
        public String toString() {
            return getClass().getSimpleName();
        }
    }

    public static class StatementsNode extends Node {
    }

    public static class Statement {
        public static class VarDefNode extends Node {
            private final String name;
            private final Node value;

            public VarDefNode(String name, Node value) {
                this.name = name;
                this.value = value;
            }

            public String getName() {
                return name;
            }

            public Node getValue() {
                return value;
            }

            @Override
            public String toString() {
                return "VarDefNode{" +
                        "name='" + name + '\'' +
                        ", value=" + value +
                        '}';
            }
        }

        public static class VarSetNode extends Node {
            private final String name;
            private final Node value;

            public VarSetNode(String name, Node value) {
                this.name = name;
                this.value = value;
            }

            public String getName() {
                return name;
            }

            public Node getValue() {
                return value;
            }

            @Override
            public String toString() {
                return "VarSetNode{" +
                        "name='" + name + '\'' +
                        ", value=" + value +
                        '}';
            }
        }

        public static class CallNode extends Node {
            private final String name;
            private final List<Node> args;

            public CallNode(String name, List<Node> args) {
                this.name = name;
                this.args = args;
            }

            public String getName() {
                return name;
            }

            public List<Node> getArgs() {
                return args;
            }

            @Override
            public String toString() {
                return "CallNode{" +
                        "name='" + name + '\'' +
                        ", args=" + args +
                        '}';
            }
        }
    }

    public static class Literal {
        public static class NumberNode extends Node {
            private final double value;

            public NumberNode(double value) {
                this.value = value;
            }

            public double getValue() {
                return value;
            }

            @Override
            public String toString() {
                return "NumberNode{" +
                        "value=" + value +
                        '}';
            }
        }

        public static class StringNode extends Node {
            private final String value;

            public StringNode(String value) {
                this.value = value;
            }

            public String getValue() {
                return value;
            }

            @Override
            public String toString() {
                return "StringNode{" +
                        "value='" + value + '\'' +
                        '}';
            }
        }

        public static class VariableNode extends Node {
            private final String name;

            public VariableNode(String name) {
                this.name = name;
            }

            public String getName() {
                return name;
            }

            @Override
            public String toString() {
                return "VariableNode{" +
                        "name='" + name + '\'' +
                        '}';
            }
        }
    }
}
