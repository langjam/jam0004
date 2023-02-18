package dev.syncclient.pling.executor;


public interface Builtin {
    void load(StateNode root);

    String description();
}
