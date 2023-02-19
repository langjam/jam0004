const Tone = require('tone')

const synth = new Tone.Synth().toDestination()
const playNote = (note, duration, onComplete) => {
    synth.triggerAttackRelease(note, duration)
    setTimeout(onComplete, Tone.Time(duration).toMilliseconds())
}

module.exports = {
    playNote,
}