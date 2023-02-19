const Tone = require('tone')

const synth = new Tone.PolySynth().toDestination()

const sixteenthNote = () => {
    return new Tone.Time("16n").toMilliseconds()
}

const playNote = (note, duration) => {
    synth.triggerAttackRelease(note, duration)
}

module.exports = {
    playNote,
    sixteenthNote
}