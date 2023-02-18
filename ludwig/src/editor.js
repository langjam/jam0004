// Create the text area
const textArea = document.createElement('textarea')
document.body.appendChild(textArea)

// This is the function that runs on the input text
const registerInterpreter = interpreter => {
    textArea.addEventListener('input', () => interpreter(textArea.value), false)
}

// Create the note display
const noteDisplay = document.createElement('p')
document.body.appendChild(noteDisplay)

const displayNote = msg => noteDisplay.textContent = msg

module.exports = {
    registerInterpreter,
    displayNote
}