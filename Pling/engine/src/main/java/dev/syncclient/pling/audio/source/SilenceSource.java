package dev.syncclient.pling.audio.source;

import dev.syncclient.pling.audio.Sound;

import java.util.Arrays;

public class SilenceSource implements AudioSource {

    @Override
    public void start() {

    }

    @Override
    public int sampleCap() {
        return 4096;
    }

    @Override
    public void fillBuffer(Sound sound, short[] buffer) {
        Arrays.fill(buffer, (short) 0);
    }
}
