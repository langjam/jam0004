import { interpret, Stream, Output } from "../src/interpreter";

import * as readline from 'node:readline/promises';
import { exit, stdin as input, stdout as output } from 'node:process';
import { parseArgs } from "node:util";
import { createReadStream } from "node:fs";

class Console implements Stream, Output {
  private rl : readline.Interface;
  private buffer: string;
  private resolv: () => void;

  constructor(private quiet: boolean = false, file?: string) {
    if (!file){
      this.rl = readline.createInterface(input, output);
    } else {
      let f = createReadStream(file).on("error", () => {
        console.error("Error when opening file", file);
        exit(1);
      });
      this.rl = readline.createInterface(f, output);
    }
    this.resolv = () => {};
    this.buffer = "";

    this.rl.setPrompt("");
    this.rl.pause();

    this.rl.on("line", (line) => {
      this.buffer = this.buffer + line + "\n";
      this.resolv();
    });
  }

  private async loadBuffer() {
    this.rl.resume();
    await new Promise<void>((resolv) => {
      this.resolv = () => {
        this.rl.pause();
        resolv();
      }
    });
  }

  async next(): Promise<string | null> {
    if (this.buffer.length === 0) {
      await this.loadBuffer();
    }

    if (this.buffer.length === 0) return null;

    let nextVal = this.buffer[0];
    this.buffer = this.buffer.slice(1);

    return nextVal;
  }
  async peek(): Promise<string | null> {
    if (this.buffer.length === 0) {
      await this.loadBuffer();
    }

    if (this.buffer.length === 0) return null;

    let nextVal = this.buffer[0];
    return nextVal;
  }

  close(): void {
    this.rl.close();
  }

  async log(text: string): Promise<void> {
    if (!this.quiet) console.log(text);
  }

  async out(o: any): Promise<void> {
    console.log(o);
  }

  async err(e: any): Promise<void> {
    console.error(e);
  }

}

async function main() {
  let options = {quiet: {type: 'boolean', short: 'q'}, file: {type: 'string', short: 'f'}};
  let args = parseArgs({args: process.argv.slice(2), options, strict: false} as any)

  let quiet = args.values.quiet as boolean || false;
  let file = args.values.file as string;

  const consl = new Console(quiet, file);
  interpret(consl, consl);
}

main();
