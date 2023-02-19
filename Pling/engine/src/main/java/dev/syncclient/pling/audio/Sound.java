package dev.syncclient.pling.audio;

import dev.syncclient.pling.audio.pipeline.AudioPipelineDescriptor;
import dev.syncclient.pling.audio.source.AudioSource;
import java.util.LinkedList;

import static org.lwjgl.openal.AL10.*;

public class Sound extends Thread {
    public static final int FREQUENCY = 22050;
    public static final int CAP = 1024;
    private final AudioPipelineDescriptor descriptor = AudioPipelineDescriptor.silence();
    private boolean running = false;
    private int locationHash = 0;

    public Sound() {
        super("Sound");
    }


    public void fillSine() {
//        for (int i = 0; i < BUFFER_SIZE; i+=2) {
//            float t = (float) ((2.0f * PI * omega * (i + lastOffset)) / ((float) NUM_SAMPLES));
//
//            short VV = (short) (volume * sin(t));
//
//            // 16-bit sample: 2 bytes
//            jbuffers[currentBuffer][i * 2] = (short) (VV & 0xFF);
//            jbuffers[currentBuffer][i * 2 + 1] = (short) (VV >> 8);
//        }
//
//        lastOffset += BUFFER_SIZE / 2;
//        lastOffset %= NUM_SAMPLES; // was FSignalFreq
//
//        short realHeight = (short) (volume * 32768);
//        for (int i = 0; i < jbuffers[currentBuffer].length; i += 2) {
//            jbuffers[currentBuffer][i] = realHeight;
//            jbuffers[currentBuffer][i + 1] = (short) -realHeight;
//        }
    }

    @Override
    public void run() {
        LinkedList<Integer> bufferQueue = new LinkedList<>();
        int[] helloBuffer = new int[16];
        int[] helloSource = new int[1];

        AudioSource src = descriptor.source();
        src.start();

        alGenBuffers(helloBuffer);

        for (int i = 0; i < 16; ++i) {
            bufferQueue.add(helloBuffer[i]);
        }

        alGenSources(helloSource);
        short[] buffer = new short[CAP];
        int samplesIn;
        int availBuffers;
        int myBuff;

        while (running) {
            availBuffers = alGetSourcei(helloSource[0], AL_BUFFERS_PROCESSED);

            if (availBuffers > 0) {
                int[] buffHolder = new int[availBuffers];
                alSourceUnqueueBuffers(helloSource[0], buffHolder);
                for (int i = 0; i < availBuffers; ++i) {
                    bufferQueue.add(buffHolder[i]);
                }
            }

            // Do location stuff
            if (locationHash != descriptor.location().hashCode()) {
                locationHash = descriptor.location().hashCode();
                alSource3f(helloSource[0], AL_POSITION, (float) descriptor.location().x, (float) descriptor.location().y, (float) descriptor.location().z);
            }

            // Poll capture device

            samplesIn = src.sampleCap();
            if (samplesIn > CAP) {
                src.fillBuffer(this, buffer);

                if (!bufferQueue.isEmpty()) {
                    myBuff = bufferQueue.remove(0);
                    alBufferData(myBuff, AL_FORMAT_MONO16, buffer, FREQUENCY);
                    alSourceQueueBuffers(helloSource[0], myBuff);

                    int sState = alGetSourcei(helloSource[0], AL_SOURCE_STATE);
                    if (sState != AL_PLAYING) {
                        alSourcePlay(helloSource[0]);
                    }
                }
            }

            System.gc();
        }
    }

    public void start() {
        running = true;
        super.start();
    }

    public void close() {
        running = false;
    }

    public AudioPipelineDescriptor getDescriptor() {
        return descriptor;
    }
}
