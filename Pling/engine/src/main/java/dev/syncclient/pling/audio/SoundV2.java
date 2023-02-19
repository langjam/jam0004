package dev.syncclient.pling.audio;

import java.util.List;

import static java.lang.Math.PI;
import static java.lang.Math.sin;
import static org.lwjgl.openal.AL10.*;

public class SoundV2 extends Thread {
    private static final int BUFFER_SIZE = 22050;
    private static final int NUM_SAMPLES = 44100;
    private static final int NUM_BUFFERS = 2;
    private boolean playing = false;
    private int[] buffers = new int[NUM_BUFFERS];
    private float[][] jbuffers = new float[NUM_BUFFERS][NUM_SAMPLES];
    private int currentBuffer = 0;
    private int lastOffset = 0;
    private float omega = 440.0f;
    private float volume = 0.5f;

    public SoundV2() {
        super("SoundV2");
        start();
    }

    void streamBuffer(int bufferId) {
        // get sound to the buffer somehow - load from file, read from input channel (queue), generate etc.
        fillSine();

        // submit more data to OpenAL
        alBufferData(bufferId, AL_FORMAT_MONO16, jbuffers[currentBuffer], jbuffers[currentBuffer].length);
    }


    public void fillSine() {
        for (int i = 0; i < BUFFER_SIZE; i++) {
            float t = (float) ((2.0f * PI * omega * (i + lastOffset)) / ((float) NUM_SAMPLES));

            short VV = (short) (volume * sin(t));

            // 16-bit sample: 2 bytes
            jbuffers[currentBuffer][i * 2] = VV & 0xFF;
            jbuffers[currentBuffer][i * 2 + 1] = VV >> 8;
        }

        lastOffset += BUFFER_SIZE / 2;
        lastOffset %= NUM_SAMPLES; // was FSignalFreq
    }

    @Override
    public void run() {
        for (int i = 0; i < NUM_BUFFERS; i++) {
            buffers[i] = alGenBuffers();
            streamBuffer(buffers[i]);
        }

        alSourceQueueBuffers(1, buffers);

        while (true) {
            int processed = alGetSourcei(1, AL_BUFFERS_PROCESSED);
            while (processed-- > 0) {
                int buffer = alSourceUnqueueBuffers(1);
                streamBuffer(buffer);
                alSourceQueueBuffers(1, buffer);
            }

            if (alGetSourcei(1, AL_SOURCE_STATE) != AL_PLAYING) {
                alSourcePlay(1);
            }
        }
    }

    public static void main(String[] args) {
        AudioController controller = new AudioController();
        controller.init(List.of());
        SoundV2 soundV2 = new SoundV2();

    }
}
