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
    private long device;
    private long context;
    private ALCCapabilities deviceCaps;

    @Override
    public void load(StateNode root) {
        root.children().add(new FunctionStateNode("init", "Initializes the audio system", this::init));
    }

    private Object init(List<Object> objects) {
        device = alcOpenDevice((ByteBuffer) null);
        if (device == NULL) {
            throw new IllegalStateException("Failed to open the default device.");
        }

        deviceCaps = ALC.createCapabilities(device);
        context = alcCreateContext(device, (IntBuffer) null);
        if (context == NULL) {
            throw new IllegalStateException("Failed to create an OpenAL context.");
        }

        alcSetThreadContext(device);
        AL.createCapabilities(deviceCaps);
        return null;
    }
}
