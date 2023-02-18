package dev.syncclient.pling.audio;

import dev.syncclient.pling.executor.Builtin;
import dev.syncclient.pling.executor.FunctionStateNode;
import dev.syncclient.pling.executor.StateNode;


import org.lwjgl.*;
import org.lwjgl.openal.*;
import org.lwjgl.stb.*;

import java.nio.*;
import java.util.*;

import static java.lang.Math.*;
import static org.lwjgl.openal.AL10.*;
import static org.lwjgl.openal.ALC10.*;
import static org.lwjgl.openal.EXTThreadLocalContext.*;
import static org.lwjgl.openal.SOFTHRTF.*;
import static org.lwjgl.system.MemoryUtil.*;

import java.util.List;

public class AudioController implements Builtin {
    protected static final int SAMPLE_RATE = 16 * 1024;
    private final HashMap<Double, Sound> sounds = new HashMap<>();
    private double nextHandle = 0;
    private long device;
    private long context;
    private ALCCapabilities deviceCaps;

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

        deviceCaps = ALC.createCapabilities(device);
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

    private Object isInitialized(List<Object> objects) {
        return (device != NULL && context != NULL) ? 1 : 0;
    }
}
