import { interpret, Stream, Output } from "../src/interpreter";

import * as readline from 'node:readline/promises';
import { stdin as input, stdout as output } from 'node:process';

class Console implements Stream, Output {
  rl : readline.Interface;
  buffer: string;
  constructor() {
    this.rl = readline.createInterface(input, output);
    this.buffer = "";
  }

  private async loadBuffer() {
    try {
      this.buffer = await this.rl.question("")
    } catch (e) {}
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
    console.log(text);
  }

  async out(o: any): Promise<void> {
    console.log(o);
  }

  async err(e: any): Promise<void> {
    console.error(e);
  }

}

async function main() {
  const consl = new Console();
  interpret(consl, consl);
}

main();