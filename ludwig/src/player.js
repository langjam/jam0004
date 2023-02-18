const Tone = require('tone')

const synth = new Tone.Synth().toDestination()
const playNote = (pitch, octave, duration) => synth.triggerAttackRelease(pitch + octave, duration + "n")

module.exports = {
    playNote
}