package dev.syncclient.pling.audio.pipeline;

import dev.syncclient.pling.audio.pipeline.fx.Fx;
import dev.syncclient.pling.audio.pipeline.fx.LowPassFX;
import dev.syncclient.pling.audio.source.AudioSource;
import dev.syncclient.pling.audio.source.SilenceSource;
import dev.syncclient.pling.utils.Location;
import dev.syncclient.pling.utils.fvec.FVec;
import dev.syncclient.pling.utils.fvec.FVecArrayListImpl;

import java.util.Objects;

public final class AudioPipelineDescriptor {
    private AudioSource source;
    private FVec<Fx> directEffects;
    private Location location;

    public AudioPipelineDescriptor(
            AudioSource source,
            FVec<Fx> directEffects,
            Location location
    ) {
        this.source = source;
        this.directEffects = directEffects;
        this.location = location;
    }

    public void source(AudioSource source) {
        this.source = source;
    }

    public void addEffect(Fx effect) {
        directEffects.add(effect);
    }

    public void removeEffect(Fx effect) {
        directEffects.drop(effect);
    }

    public void clearEffects() {
        for (int i = 0; i < directEffects.size(); i++) {
            directEffects.drop(i);
        }
    }


    public void location(Location location) {
        this.location = location;
    }


    public static AudioPipelineDescriptor silence() {
        var fx = new FVecArrayListImpl<Fx>();

        fx.add(new LowPassFX(0.5));

        return new AudioPipelineDescriptor(new SilenceSource(), fx, Location.ORIGIN);
    }

    public AudioSource source() {
        return source;
    }

    public FVec<Fx> directEffects() {
        return directEffects;
    }

    public Location location() {
        return location;
    }

    public void xyz(float x, float y, float z) {
        location.x = x;
        location.y = y;
        location.z = z;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) return true;
        if (obj == null || obj.getClass() != this.getClass()) return false;
        var that = (AudioPipelineDescriptor) obj;
        return Objects.equals(this.source, that.source) &&
                Objects.equals(this.directEffects, that.directEffects) &&
                Objects.equals(this.location, that.location);
    }

    @Override
    public int hashCode() {
        return Objects.hash(source, directEffects, location);
    }

    @Override
    public String toString() {
        return "AudioPipelineDescriptor[" +
                "source=" + source + ", " +
                "directEffects=" + directEffects + ", " +
                "location=" + location + ']';
    }

}
