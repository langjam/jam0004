package dev.syncclient.pling.utils.fvec;

public interface FVec<T> extends Iterable<T> {
    T get(int index);
    void set(int index, T value);
    void add(T value);
    void drop(int index);
    void drop(T value);

    int size();
}
