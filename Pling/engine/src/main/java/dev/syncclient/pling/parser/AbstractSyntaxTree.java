package dev.syncclient.pling.parser;

import dev.syncclient.pling.executor.StateTree;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;

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

        public void print(int indent, Consumer<String> func) {
            for (int i = 0; i < indent; i++) {
                func.accept(" ");
            }
            func.accept(this.toString());
            func.accept("\n");
            for (Node child : children) {
                child.print(indent + 2, func);
            }
        }

        @Override
        public String toString() {
            return getClass().getSimpleName();
        }
    }

    public static class StatementsNode extends Node {}
    public static class FuncDefNode extends Node {
        private final String name;
        private final List<Node> args;
        private final Node body;

        public FuncDefNode (String name, List<Node> args, Node body) {
            this.name = name;
            this.args = args;
            this.body = body;
        }

        public String getName() {
            return name;
        }

        public List<Node> getArgs() {
            return args;
        }

        public Node getBody() {
            return body;
        }

        public Object run(List<Object> args) {
            StateTree st = StateTree.getInstance();

            if (!st.contextExists(getName())) {
                st.createContextForFunc(getName());
            }

            st.pushContext(getName());

            for (int i = 0; i < getArgs().size(); i++) {
                st.pushVar(((Literal.VariableNode) getArgs().get(i)).getName(), args.get(i));
            }

            st.getInterpreter().exec(getBody());

            // Check for a return value
            if (st.hasLocalVar("__return")) {
                Object ret = st.findVar("__return").getValue();
                st.popAndDestroy();
                return ret;
            }

            st.popAndDestroy();

            return null;
        }

        @Override
        public String toString() {
            return "FuncDefNode{" +
                    "name='" + name + '\'' +
                    ", args=" + args +
                    ", body=" + body +
                    '}';
        }
    }

    public static class BranchNode extends Node {
        private final Node condition;
        private final Node body;
        private final BranchNode subordiante;

        public BranchNode(Node condition, Node body, BranchNode subordiante) {
            this.condition = condition;
            this.body = body;
            this.subordiante = subordiante;
        }

        public Node getCondition() {
            return condition;
        }

        public Node getBody() {
            return body;
        }

        public BranchNode getSubordiante() {
            return subordiante;
        }

        @Override
        public String toString() {
            return "BranchNode{" +
                    "condition=" + condition +
                    ", body=" + body +
                    ", subordiante=" + subordiante +
                    '}';
        }
    }

    public static class LoopNode extends Node {
        private final Node condition;
        private final Node body;

        public LoopNode(Node condition, Node body) {
            this.condition = condition;
            this.body = body;
        }

        public Node getCondition() {
            return condition;
        }

        public Node getBody() {
            return body;
        }

        @Override
        public String toString() {
            return "LoopNode{" +
                    "condition=" + condition +
                    ", body=" + body +
                    '}';
        }
    }

    public static class ForLoopNode extends Node {
        private final Node condition;
        private final Node action;
        private final Node body;

        public ForLoopNode(Node condition, Node action, Node body) {
            this.action = action;
            this.condition = condition;
            this.body = body;
        }

        public Node getCondition() {
            return condition;
        }

        public Node getAction() {
            return action;
        }

        public Node getBody() {
            return body;
        }

        @Override
        public String toString() {
            return "ForLoopNode{" +
                    "condition=" + condition +
                    "action=" + action +
                    ", body=" + body +
                    '}';
        }
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

    public static class ReturnNode extends Node {
        private final Node value;

        public ReturnNode(Node value) {
            this.value = value;
        }

        public Node getValue() {
            return value;
        }

        @Override
        public String toString() {
            return "ReturnNode{" +
                    "value=" + value +
                    '}';
        }
    }

    public static class UseNode extends Node {
        private final String name;

        public UseNode(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }

        @Override
        public String toString() {
            return "UseNode{" +
                    "name='" + name + '\'' +
                    '}';
        }
    }
}
