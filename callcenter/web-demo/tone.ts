const AudioCtx = window.AudioContext || (window as any).webkitAudioContext as AudioContext || (window as any).mozAudioContext as AudioContext;

class Tone {
  status: number;
  osc1: OscillatorNode;
  osc2: OscillatorNode;
  gainNode: GainNode;
  filter: BiquadFilterNode;
  constructor(private context: AudioContext, public freq1: number, public freq2: number) {
    this.status = 0;

    this.osc1 = this.context.createOscillator();
    this.osc2 = this.context.createOscillator();
    this.osc1.frequency.value = this.freq1;
    this.osc2.frequency.value = this.freq2;

    this.gainNode = this.context.createGain();
    this.gainNode.gain.value = 0.25;

    this.filter = this.context.createBiquadFilter();
    this.filter.type = "lowpass";
    this.filter.frequency.value = 8000;

    this.osc1.connect(this.gainNode);
    this.osc2.connect(this.gainNode);

    this.gainNode.connect(this.filter);
    this.filter.connect(this.context.destination);
  }

  start() {
    this.setup();
    this.osc1.start(0);
    this.osc2.start(0);
    this.status = 1;
  }

  stop() {
    this.osc1.stop(0);
    this.osc2.stop(0);
    this.status = 0;
  }

  setup() {
    this.osc1 = this.context.createOscillator();
    this.osc2 = this.context.createOscillator();
    this.osc1.frequency.value = this.freq1;
    this.osc2.frequency.value = this.freq2;

    this.gainNode = this.context.createGain();
    this.gainNode.gain.value = 0.25;

    this.filter = this.context.createBiquadFilter();
    this.filter.type = "lowpass";

    this.osc1.connect(this.gainNode);
    this.osc2.connect(this.gainNode);

    this.gainNode.connect(this.filter);
    this.filter.connect(this.context.destination);
  }
}

var dtmfFrequencies : any = {
	"1": {f1: 697, f2: 1209},
	"2": {f1: 697, f2: 1336},
	"3": {f1: 697, f2: 1477},
	"4": {f1: 770, f2: 1209},
	"5": {f1: 770, f2: 1336},
	"6": {f1: 770, f2: 1477},
	"7": {f1: 852, f2: 1209},
	"8": {f1: 852, f2: 1336},
	"9": {f1: 852, f2: 1477},
	"*": {f1: 941, f2: 1209},
	"0": {f1: 941, f2: 1336},
	"#": {f1: 941, f2: 1477}
}

const context = AudioCtx ? new AudioCtx() : null;

export function playTone(key: string, length: number) : Promise<void>{
  if (!context) return Promise.resolve();

  const frequencyPair = dtmfFrequencies[key];
  const dtmf = new Tone(context, frequencyPair.f1, frequencyPair.f2);

	if (dtmf.status == 0){
		dtmf.start();
	}

  return new Promise((resolv) => {
    setTimeout(() => {
      dtmf.stop();
      resolv();
    }, length);
  });
}
