// Create the text area
const textArea = document.createElement('textarea')
document.body.appendChild(textArea)

// This is the function that runs on the input text
const registerInterpreter = interpreter => {
    textArea.addEventListener('input', () => interpreter(textArea.value), false)
}

const runButton = document.createElement("button")
runButton.textContent = "RUN"
document.body.appendChild(runButton)
const registerRunClick = cont => {
    runButton.addEventListener("click", () => cont())
}

// Create the note display
const noteDisplay = document.createElement('p')
document.body.appendChild(noteDisplay)

const displayNote = msg => noteDisplay.textContent = msg


module.exports = {
    registerInterpreter,
    displayNote,
    registerRunClick
}