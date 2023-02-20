package dev.syncclient.pling.utils.fvec;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * The Fast Vector implementation using an ArrayList.
 * Useful when you have data that is not going to change in size as often as it is going to be accessed.
 *
 * @param <T> The type of the vector.
 */
public class FVecArrayListImpl<T> implements FVec<T> {
    private final ArrayList<T> list = new ArrayList<>();

    @Override
    public T get(int index) {
        return list.get(index);
    }

    @Override
    public void set(int index, T value) {
        list.set(index, value);
    }

    @Override
    public void add(T value) {
        list.add(value);
    }

    @Override
    public void drop(int index) {
        list.remove(index);
    }

    @Override
    public void drop(T value) {
        list.remove(value);
    }

    @Override
    public int size() {
        return list.size();
    }

    @Override
    public Iterator<T> iterator() {
        return list.iterator();
    }
}
