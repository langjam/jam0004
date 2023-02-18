package dev.syncclient.pling.executor;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;

public class VarStateNode extends StateNode {
    private Object value;

    public VarStateNode(String name, String docs, Object value) {
        super(name, docs, Type.FUNCTION, new ArrayList<>());
        this.value = value;
    }

    public Object getValue() {
        return value;
    }

    public void setValue(Object value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return "VarStateNode{" +
                "value=" + value +
                '}';
    }
}
