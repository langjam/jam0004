package dev.syncclient.pling.audio;

import dev.syncclient.pling.audio.source.SineSource;

import java.util.List;

public class APLDemo {
    public static void main(String[] args) {
        AudioController controller = new AudioController();
        controller.init(List.of());

        Sound sound = new Sound();

        SineSource src = new SineSource();
        src.setFrequency(440);
        src.setVolume(1);
        sound.getDescriptor().source(src);

        sound.start();

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        src.setFrequency(880);

        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }


        sound.close();
    }
}
