package dev.syncclient.pling.executor;

import java.util.List;
import java.util.Objects;

import static dev.syncclient.pling.executor.StateTree.indent;

public class StateNode {
    private final String name;
    private final String docs;
    private final Type type;
    private final List<StateNode> children;

    public StateNode(
            String name,
            String docs,
            Type type,
            List<StateNode> children
    ) {
        this.name = name;
        this.docs = docs;
        this.type = type;
        this.children = children;
    }

    public String name() {
        return name;
    }

    public String docs() {
        return docs;
    }

    public Type type() {
        return type;
    }

    public List<StateNode> children() {
        return children;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) return true;
        if (obj == null || obj.getClass() != this.getClass()) return false;
        var that = (StateNode) obj;
        return Objects.equals(this.name, that.name) &&
                Objects.equals(this.docs, that.docs) &&
                Objects.equals(this.type, that.type) &&
                Objects.equals(this.children, that.children);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, docs, type, children);
    }

    @Override
    public String toString() {
        StringBuilder childrenStr = new StringBuilder();

        for (StateNode child : this.children) {
            childrenStr.append(child.toString()).append("\n");
        }

        return "StateNode[\n" +
                "  name=" + name + "\n" +
                "  docs=" + docs + "\n" +
                "  type=" + type + "\n" +
                "  children=[\n" + indent(1, childrenStr.toString()) + "  ]\n" +
                "]";
    }

    public enum Type {
        FUNCTION,
        CLASS,
        MODULE,
        PACKAGE
    }
}
