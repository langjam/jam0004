package dev.syncclient.pling.audio;

import static org.lwjgl.openal.AL10.*;

import org.lwjgl.openal.*;

import java.util.List;

public class Sound {

    public static int bufferLength = AudioController.SAMPLE_RATE;

    public static void main(String[] args) {
        AudioController controller = new AudioController();
        controller.init(List.of());

        sineWave(4750);
    }

    public static void sineWave(int height) {
       alGenBuffers();
       int buffer = 1;
       int source = 1;

       float[] data = new float[bufferLength * 2];

        for (int i = 0; i < bufferLength; ++i) {
            data[i*2] = (float) (Math.sin(2 * Math.PI * height * i / bufferLength) * 32.767);
            data[i*2+1] = (float) (-1 * Math.sin(2 * Math.PI * height * i / bufferLength) *	-32.768); // antiphase
        }

        alBufferData(buffer, AL_FORMAT_STEREO16, data, height);
        alGenSources();
        alSourcei(source, AL_BUFFER, buffer);
        alSourcei(source, AL_LOOPING, AL_TRUE);
        alSourcePlay(source);
    }
}
