package dev.syncclient.pling.audio.source;

import dev.syncclient.pling.audio.Sound;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SineSource implements AudioSource {
    private double frequency;
    private double volume;
    private double lastOffset;

    @Override
    public void start() {
        // We don't need to do anything here
    }

    @Override
    public int sampleCap() {
        return 8192;
    }

    @Override
    public void fillBuffer(Sound sound, short[] buffer) {
        double realVolume = volume * 32767;
        double offset = lastOffset;
        double step = (2 * Math.PI * frequency) / Sound.FREQUENCY;

        for (int i = 0; i < buffer.length; ++i) {
            buffer[i] = (short) (realVolume * Math.sin(offset));
            offset += step;
        }

        lastOffset = offset;
        lastOffset %= 2 * Math.PI;
    }

    public void setVolume(double volume) {
        this.volume = volume * 0.01;
    }

    public double getVolume() {
        return volume * 100;
    }
}
