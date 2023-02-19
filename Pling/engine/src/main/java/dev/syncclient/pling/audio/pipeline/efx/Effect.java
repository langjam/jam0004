package dev.syncclient.pling.audio.pipeline.efx;

import static org.lwjgl.openal.AL10.*;
import static org.lwjgl.openal.EXTEfx.*;

public class Effect {

    public static void setPitch(int sourceId, float pitch) {
        alSourcef(sourceId, AL_PITCH, pitch);
    }

    public static void addReverb(int sourceId) {
        // Create a reverb effect
        int reverbEffect = alGenEffects();

        // Set the effect type
        alEffecti(reverbEffect, AL_EFFECT_TYPE, AL_EFFECT_REVERB);

        // Set the effect properties
        alEffectf(reverbEffect, AL_REVERB_DENSITY, 1.0f);
        alEffectf(reverbEffect, AL_REVERB_DIFFUSION, 1.0f);
        alEffectf(reverbEffect, AL_REVERB_GAIN, 0.32f);
        alEffectf(reverbEffect, AL_REVERB_GAINHF, 0.89f);
        alEffectf(reverbEffect, AL_REVERB_DECAY_TIME, 1.49f);
        alEffectf(reverbEffect, AL_REVERB_DECAY_HFRATIO, 0.83f);
        alEffectf(reverbEffect, AL_REVERB_REFLECTIONS_GAIN, 0.05f);
        alEffectf(reverbEffect, AL_REVERB_REFLECTIONS_DELAY, 0.007f);
        alEffectf(reverbEffect, AL_REVERB_LATE_REVERB_GAIN, 1.26f);
        alEffectf(reverbEffect, AL_REVERB_LATE_REVERB_DELAY, 0.011f);
        alEffectf(reverbEffect, AL_REVERB_AIR_ABSORPTION_GAINHF, 0.994f);
        alEffectf(reverbEffect, AL_REVERB_ROOM_ROLLOFF_FACTOR, 0.0f);
        alEffecti(reverbEffect, AL_REVERB_DECAY_HFLIMIT, AL_FALSE);
    }
}
