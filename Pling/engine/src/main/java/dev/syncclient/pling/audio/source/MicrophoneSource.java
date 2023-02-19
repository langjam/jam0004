package dev.syncclient.pling.audio.source;

import dev.syncclient.pling.audio.Sound;

import java.nio.ByteBuffer;

import static dev.syncclient.pling.audio.Sound.CAP;
import static dev.syncclient.pling.audio.Sound.FREQUENCY;
import static org.lwjgl.openal.AL10.AL_FORMAT_MONO16;
import static org.lwjgl.openal.ALC11.*;

public class MicrophoneSource implements AudioSource {
    private long inputDevice;

    @Override
    public void start() {
        inputDevice = alcCaptureOpenDevice((ByteBuffer) null, FREQUENCY, AL_FORMAT_MONO16, FREQUENCY / 2);
        alcCaptureStart(inputDevice);
    }

    @Override
    public int sampleCap() {
        int[] samples = new int[1];
        alcGetIntegerv(inputDevice, ALC_CAPTURE_SAMPLES, samples);
        return samples[0];
    }

    @Override
    public void fillBuffer(Sound sound, short[] buffer) {
        alcCaptureSamples(inputDevice, buffer, CAP);
    }
}
