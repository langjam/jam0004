package dev.syncclient.pling.audio;

import dev.syncclient.pling.executor.Builtin;
import dev.syncclient.pling.executor.FunctionStateNode;
import dev.syncclient.pling.executor.StateNode;


import org.lwjgl.openal.*;

import java.nio.*;
import java.util.*;

import static org.lwjgl.openal.ALC10.*;
import static org.lwjgl.openal.EXTThreadLocalContext.*;
import static org.lwjgl.system.MemoryUtil.*;

import java.util.List;

public class AudioController implements Builtin {
    private final HashMap<Double, Sound> sounds = new HashMap<>();
    private double nextHandle = 0;
    private long device;
    private long context;

    @Override
    public void load(StateNode root) {
        root.children().add(new FunctionStateNode(
                "audio.begin",
                "Initializes the audio system",
                "#audio.begin",
                this::init
        ));

        root.children().add(new FunctionStateNode(
                "audio.initted",
                "Returns 1 if the audio system is initialized",
                "#audio.initted -> [result]",
                this::isInitialized
        ));

        root.children().add(new FunctionStateNode(
                "audio.new",
                "Creates a new sound handle (number)",
                "#audio.new -> [handle]",
                this::createSound
        ));

        root.children().add(new FunctionStateNode(
                "audio.tostring",
                "Get printable information about this handle",
                "#audio.tostring [handle] -> [info]",
                this::showHandle
        ));

        root.children().add(new FunctionStateNode(
                "audio.sine",
                "Generate a sine wave",
                "#audio.sine [handle] [frequency] [volume]",
                this::sineWave
        ));

        root.children().add(new FunctionStateNode(
                "audio.stop",
                "Stops the sound",
                "#audio.stop [handle]",
                this::stop
        ));
    }

    @Override
    public String description() {
        return "This module provides access to the audio output system. Import it with `use audio;`";
    }

    public Object init(List<Object> objects) {
        device = alcOpenDevice((ByteBuffer) null);
        if (device == NULL) {
            throw new IllegalStateException("Failed to open the default device.");
        }

        ALCCapabilities deviceCaps = ALC.createCapabilities(device);
        context = alcCreateContext(device, (IntBuffer) null);
        if (context == NULL) {
            throw new IllegalStateException("Failed to create an OpenAL context.");
        }

        alcSetThreadContext(context);
        ALC10.alcMakeContextCurrent(context);
        AL.createCapabilities(deviceCaps);
        return null;
    }

    private Object createSound(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = nextHandle++;
        sounds.put(handle, new Sound());

        return handle;
    }

    private Object showHandle(List<Object> objects) {
        Double handle = (Double) objects.get(0);

        if (!sounds.containsKey(handle)) {
            throw new IllegalStateException("Invalid handle");
        }

        return sounds.get(handle).toString();
    }

    private Object sineWave(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = (Double) objects.get(0);
        float freq = ((Double) objects.get(1)).floatValue();
        float volume = ((Double) objects.get(2)).floatValue();

        if (!sounds.containsKey(handle)) {
            throw new IllegalStateException("Invalid handle");
        }

        sounds.get(handle).sineWave(freq, volume);
        return null;
    }

    private Object stop(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = (Double) objects.get(0);

        if (!sounds.containsKey(handle)) {
            throw new IllegalStateException("Invalid handle");
        }

        sounds.get(handle).stop();
        return null;
    }

    private Object isInitialized(List<Object> objects) {
        return (device != NULL && context != NULL) ? 1 : 0;
    }
}
