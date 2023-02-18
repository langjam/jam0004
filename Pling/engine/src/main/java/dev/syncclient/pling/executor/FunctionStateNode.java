package dev.syncclient.pling.executor;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class FunctionStateNode extends StateNode {
    private final String usage;
    private final Function<List<Object>, Object> function;

    public FunctionStateNode(String name, String docs, String usage, Function<List<Object>, Object> function) {
        super(name, docs, Type.FUNCTION, new ArrayList<>());
        this.usage = usage;
        this.function = function;
    }

    public FunctionStateNode(String name, String docs, Function<List<Object>, Object> function) {
        this(name, docs, "", function);
    }

    public String getUsage() {
        return usage;
    }

    public Function<List<Object>, Object> getFunction() {
        return function;
    }

    @Override
    public String toString() {
        return "FunctionStateNode[" +
                "name=" + name() + ", " +
                "docs=" + docs() + ", " +
                "type=" + type() + ", " +
                "children=" + children() + ']';
    }
}
