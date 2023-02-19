const Tone = require('tone')

const synth = new Tone.Synth().toDestination()
const playNote = (note, duration) => synth.triggerAttackRelease(note, duration + "n")

const runAfterDuration = (time, cont) => {
    let timeInMilliseconds = Tone.Time(time).toMilliseconds
    setTimeout(cont, timeInMilliseconds)
}

module.exports = {
    playNote,
    runAfterDuration
}