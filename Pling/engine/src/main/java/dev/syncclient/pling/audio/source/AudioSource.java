package dev.syncclient.pling.audio.source;

import dev.syncclient.pling.audio.Sound;

public interface AudioSource {
    void start();
    int sampleCap();
    void fillBuffer(Sound sound, short[] buffer);

    default boolean isExhausted() {
        return false;
    }
}
