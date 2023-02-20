package dev.syncclient.pling.audio;

import static org.lwjgl.openal.AL10.*;

public class SoundOld {
    private static int BufferSize = 22050;
    private static int NumSamples = 44100;
    private boolean playing = false;
    private int bufferLeft;
    private int bufferRight;
    private int source;

    public void sineWave(float freq, float volume) {
        if (!playing) {
            playing = true;
            bufferLeft = alGenBuffers();
            bufferRight = alGenBuffers();
            source = alGenSources();

            alSourceQueueBuffers(1, 2);
            switch (alGetError()) {
                case AL_INVALID_NAME -> System.out.println("Invalid name");
                case AL_INVALID_ENUM -> System.out.println("Invalid enum");
                case AL_INVALID_VALUE -> System.out.println("Invalid value");
                case AL_INVALID_OPERATION -> System.out.println("Invalid operation");
                case AL_OUT_OF_MEMORY -> System.out.println("Out of memory");
                case AL_NO_ERROR -> System.out.println("No error");
            }
            alSourceQueueBuffers(2, 1);

            switch (alGetError()) {
                case AL_INVALID_NAME -> System.out.println("Invalid name");
                case AL_INVALID_ENUM -> System.out.println("Invalid enum");
                case AL_INVALID_VALUE -> System.out.println("Invalid value");
                case AL_INVALID_OPERATION -> System.out.println("Invalid operation");
                case AL_OUT_OF_MEMORY -> System.out.println("Out of memory");
                case AL_NO_ERROR -> System.out.println("No error");
            }
        }

        int buffer = 1;
        int source = 1;

        float lastHeight = volume / 10;
        alSourcePause(source);
        System.out.println("Playing " + freq + "Hz at " + lastHeight + " volume");
        alDeleteBuffers(1);
        alGenBuffers();
        alBufferData(buffer, AL_FORMAT_MONO16, sine(lastHeight), (int) freq);
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
        alSourcePause(1);
    }
}
