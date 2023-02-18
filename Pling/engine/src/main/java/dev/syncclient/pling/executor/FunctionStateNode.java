package dev.syncclient.pling.executor;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class FunctionStateNode extends StateNode {
    private final Function<List<Object>, Object> function;

    public FunctionStateNode(String name, String docs, Function<List<Object>, Object> function) {
        super(name, docs, Type.FUNCTION, new ArrayList<>());
        this.function = function;
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
