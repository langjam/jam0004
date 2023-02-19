package dev.syncclient.pling.audio.source;

import dev.syncclient.pling.audio.Sound;
import lombok.Getter;
import lombok.Setter;

import static dev.syncclient.pling.audio.Sound.CAP;

@Getter
@Setter
public class SineSource implements AudioSource {
    private double frequency;
    private double volume;
    private double lastPhase;

    @Override
    public void start() {
        // We don't need to do anything here
    }

    @Override
    public int sampleCap() {
        return CAP + 1;
    }

    @Override
    public void fillBuffer(Sound sound, short[] buffer) {
        double phase = lastPhase;

        var phaseShift = 2 * Math.PI * frequency / Sound.DSAMPLE_RATE;
        for (int i = 0; i < CAP; i++) {
            phase += phaseShift;

            buffer[i] = (short) (volume * Math.sin(phase) * Short.MAX_VALUE);
        }

        lastPhase = phase;
    }

    public void setVolume(double volume) {
        this.volume = volume * 0.01;
    }

    public double getVolume() {
        return volume * 100;
    }

    public void setFrequency(double frequency) {
        this.frequency = frequency;
        this.lastPhase = 0;
    }
}
