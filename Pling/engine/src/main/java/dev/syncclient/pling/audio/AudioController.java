package dev.syncclient.pling.audio;

import dev.syncclient.pling.audio.source.MicrophoneSource;
import dev.syncclient.pling.audio.source.SilenceSource;
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
    private final HashMap<Double, MicrophoneSource> microphones = new HashMap<>();
    private final HashMap<Double, SilenceSource> silences = new HashMap<>();
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
                "audio.start",
                "Plays the sound",
                "#audio.start [handle]",
                this::start
        ));

        root.children().add(new FunctionStateNode(
                "audio.stop",
                "Stops the sound",
                "#audio.stop [handle]",
                this::stop
        ));

        root.children().add(new FunctionStateNode(
                "audio.microphone.new",
                "Creates a new microphone handle (number)",
                "#audio.microphone.new -> [handle]",
                this::newMicrophone
        ));

        root.children().add(new FunctionStateNode(
                "audio.silence.new",
                "Creates a new silence handle (number)",
                "#audio.silence.new -> [handle]",
                this::newSilence
        ));

        root.children().add(new FunctionStateNode(
                "audio.bindsource",
                "Binds a source to a sound for playback",
                "#audio.bindsource [handle] [source]",
                this::bindSource
        ));

        root.children().add(new FunctionStateNode(
                "audio.xyz",
                "Sets the position of the sound",
                "#audio.xyz [handle] [x] [y] [z]",
                this::setLocation
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

    private Object stop(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = (Double) objects.get(0);

        if (!sounds.containsKey(handle)) {
            throw new IllegalStateException("Invalid handle");
        }

        sounds.get(handle).close();
        return null;
    }

    private Object start(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = (Double) objects.get(0);

        if (!sounds.containsKey(handle)) {
            throw new IllegalStateException("Invalid handle");
        }

        sounds.get(handle).start();
        return null;
    }

    private Object newMicrophone(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = nextHandle++;
        microphones.put(handle, new MicrophoneSource());

        return handle;
    }

    private Object newSilence(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = nextHandle++;
        silences.put(handle, new SilenceSource());

        return handle;
    }

    private Object bindSource(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = (Double) objects.get(0);
        Double sourceHandle = (Double) objects.get(1);

        if (!sounds.containsKey(handle)) {
            throw new IllegalStateException("Invalid handle");
        }

        if (!microphones.containsKey(sourceHandle) && !silences.containsKey(sourceHandle)) {
            throw new IllegalStateException("Invalid source handle");
        }

        if (microphones.containsKey(sourceHandle)) {
            sounds.get(handle).getDescriptor().source(microphones.get(sourceHandle));
        } else {
            sounds.get(handle).getDescriptor().source(silences.get(sourceHandle));
        }

        return null;
    }

    private Object setLocation(List<Object> objects) {
        if (device == NULL || context == NULL) {
            throw new IllegalStateException("Audio system not initialized");
        }

        Double handle = (Double) objects.get(0);
        Double x = (Double) objects.get(1);
        Double y = (Double) objects.get(2);
        Double z = (Double) objects.get(3);

        if (!sounds.containsKey(handle)) {
            throw new IllegalStateException("Invalid handle");
        }

        sounds.get(handle).getDescriptor().xyz(x.floatValue(), y.floatValue(), z.floatValue());
        return null;
    }

    private Object isInitialized(List<Object> objects) {
        return (device != NULL && context != NULL) ? 1 : 0;
    }
}
