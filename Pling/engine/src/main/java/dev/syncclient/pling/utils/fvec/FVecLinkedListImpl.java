package dev.syncclient.pling.utils.fvec;

import java.util.Iterator;
import java.util.LinkedList;

/**
 * The Fast Vector implementation using a LinkedList.
 * Useful when you have data that is going to change in size as often as it is going to be accessed
 * or when you only need to access the edges of the vector.
 *
 * @param <T>
 */
public class FVecLinkedListImpl<T> implements FVec<T> {
    private final LinkedList<T> list = new LinkedList<>();

    @Override
    public T get(int index) {
        if (index == 0) {
            return list.getFirst();
        } else if (index == list.size() - 1) {
            return list.getLast();
        }

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
