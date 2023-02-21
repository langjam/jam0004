import { interpret, Output, Stream } from "../src/interpreter";
import { playTone } from "./tone";

function addDiv(parent: HTMLElement, classname: string, textContent: string): HTMLElement {
  let div = document.createElement("div");
  div.setAttribute("class", classname);
  div.innerText = textContent;
  parent.appendChild(div)

  return div
}

class UI implements Output, Stream {
  buffer: string = "";
  lastConsole: HTMLElement | null = null;
  isOutput: boolean = true;
  voice: SpeechSynthesisVoice | null = null;

  speechPromise: Promise<void> | null = null; // HACK!

  constructor(private input: HTMLTextAreaElement, private output: HTMLElement, private synth: SpeechSynthesis | null) {
    this.reset();
    this.initSynth();

  }

  reset() {
    this.speechPromise = null
    this.isOutput = true;
    this.lastConsole = null;
    this.buffer = this.input.value || "";
    this.output.innerHTML = "";
  }

  initSynth() {
      if (!this.synth) return;
    if (!this.getVoice(this.synth)) {
      this.synth = null;
      return;
    }
  }

  getVoice(synth: SpeechSynthesis) {
    const voices = synth.getVoices().filter(v => v.lang === "en-US");

    if (voices.length === 0) return null;

    this.voice =
      voices.find((v) => /google/i.test(v.name)) ||
      voices.find((v) => /microsoft/i.test(v.name) && /aria/i.test(v.name)) ||
      voices.find((v) => /microsoft/i.test(v.name) && /zira/i.test(v.name)) ||
      voices[0];

    return this.voice;
  }

  addOutput(isOutput: boolean, text: string) {
    if (!this.lastConsole) {
      this.isOutput = isOutput;
      const classname = isOutput ? "console-out" : "console-in";
      this.lastConsole = addDiv(this.output, classname, text);
    } else if (this.isOutput !== isOutput) {
      this.isOutput = isOutput;
      const classname = isOutput ? "console-out" : "console-in";
      this.lastConsole = addDiv(this.output, classname, text);
    } else {
      this.lastConsole.innerText = this.lastConsole.innerText + text;
    }
  }

  speak(text: string): Promise<void> {
    if (!this.synth || !this.voice) return Promise.resolve();
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.voice = this.voice;

    const promise = new Promise<void>(resolv => {
      utterance.onend = () => {
        this.speechPromise = null;
        resolv();
      }
    });

    this.speechPromise = promise;

    this.synth.speak(utterance);
    return promise;
  }

  async log(text: string): Promise<void> {
    this.addOutput(false, text + "\n");
    await this.speak(text);
  }
  async out(o: any): Promise<void> {
    let text = o || "";
    this.addOutput(false, text + "\n");
    await this.speak(text);
  }
  async err(e: any): Promise<void> {
    let text = e || "";

    this.addOutput(false, text + "\n");
    await this.speak(text);
  }

  async next(): Promise<string | null> {
    if (this.buffer.length === 0) return null;
    if (this.speechPromise) await this.speechPromise;

    let next = this.buffer[0];
    this.buffer = this.buffer.slice(1);

    if (/[0-9\*\#]/.test(next)) {
      await playTone(next, 200);
      this.addOutput(true, next);
    }

    return next;
  }

  async peek(): Promise<string | null> {
    if (this.buffer.length === 0) return null;
    return this.buffer[0];
  }

  close(): void {}
}

function main() {
  let input = document.getElementById("editor") as HTMLTextAreaElement;
  let output = document.getElementById("console") as HTMLElement;
  let callbtn = document.getElementById("call") as HTMLElement;

  let ui = new UI(input, output, window.speechSynthesis);

  callbtn.addEventListener("click", (e) => {
    callbtn.setAttribute("disabled", "true");

    ui.reset();
    interpret(ui, ui).then(() => {
      callbtn.removeAttribute("disabled");
    });
  });
}

if (window.speechSynthesis && (window.speechSynthesis.getVoices().length === 0)) {
  window.speechSynthesis.onvoiceschanged = () =>{
    main();
  }
} else {
  main();
}
