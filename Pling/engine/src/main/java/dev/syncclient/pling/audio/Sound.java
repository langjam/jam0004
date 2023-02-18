package dev.syncclient.pling.audio;

import static org.lwjgl.openal.AL10.*;

public class Sound {
    public void sineWave(float freq, float volume) {
        alGenBuffers();
        int buffer = 1;
        int source = 1;
        alBufferData(buffer, AL_FORMAT_MONO16, sine( volume / 10), (int)freq);
        alGenSources();
        alSourcei(source, AL_BUFFER, buffer);
        alSourcePlay(source);
    }

    private short[] sine(float height) {
        short realHeight = (short) (height * 32768);
        short[] buffer = new short[44100];
        for (int i = 0; i < buffer.length; i += 2) {
            buffer[i] = realHeight;
            buffer[i + 1] = (short) -realHeight;
        }
        return buffer;
    }

    public void stop() {
        alDeleteSources(1);
        alDeleteBuffers(1);
    }
}
