import * as Tone from 'tone'

const synth = new Tone.Synth().toDestination();

const play = (pitch, octave, duration) => synth.triggerAttackRelease(pitch + octave, duration + "n");