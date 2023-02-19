package dev.syncclient.pling.audio.pipeline.efx;

import static org.lwjgl.openal.AL10.*;

public class Effect {

    public static void setPitch(int sourceId, float pitch) {
        alSourcef(sourceId, AL_PITCH, pitch);
    }
}
