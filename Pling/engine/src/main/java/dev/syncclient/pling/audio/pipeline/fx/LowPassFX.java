package dev.syncclient.pling.audio.pipeline.fx;

public class LowPassFX implements Fx {
    private final double alpha;
    private double prevOutput;

    public LowPassFX(double alpha) {
        this.alpha = alpha;
        this.prevOutput = 0;
    }

    @Override
    public void apply(short[] sample) {
        for (int i = 0; i < sample.length; i++) {
            double input = sample[i];
            double output = alpha * prevOutput + (1 - alpha) * input;
            sample[i] = (short) ((short) output + 1);
            prevOutput = output;
        }
    }
}
