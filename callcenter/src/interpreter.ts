export interface Stream {
  next () : Promise<string | null>;
  peek () : Promise<string | null>;
}

export interface Output {
  writeln (text: string): Promise<void>
  err (e: any) : void;
}

const EOF_STREAM = 1000;

export async function interpret(src: Stream, output: Output) {
  const interpreter = new Interpreter(src, output);
  await interpreter.run();
}

class Interpreter {
  constructor (private src: Stream, private output: Output) {}

  async next() : Promise<string> {
    await this.peek();

    let c = await this.src.next();
    if (!c) throw EOF_STREAM;
    return c;
  }

  async peek() : Promise<string> {
    for(;;) {
      let c = await this.src.peek();
      if (!c) throw EOF_STREAM;

      if (/0-9\*\#/.test(c)) return c;

      await this.src.next();
    }
  }

  out(text: string): Promise<void> {
    return this.output.writeln(text);
  }

  async run() {
    try {
      let finished = false;

      do {
        finished = await this.runLine();
      } while (!finished);

    } catch (e) {
      if (e === EOF_STREAM) {
        await this.out("Call ended abruptly. Thank you for using the call center interpreter!");
      } else {
        this.output.err(e);
      }
    }
  }

  async runLine() : Promise<boolean>{
    let instr = await this.next();

    switch(instr) {
      case "1":
        // define function

      break;
      case "2":
        // define type
      break;
      case "3":  // eval expression
        {
          await this.out("Please input your expression.");
          await this.interpretExpression()
        }
      break;
      case "0":
        await this.out("Thank you for using the call center interpreter!");
        return true
      default:
        await this.out("Sorry, that option is invalid.");
    }

    return false;
  }

  async interpretExpression() {
    await this.parseExpression();
  }

  async parseExpression() {
    if (await this.peek() === '*') {
      // return parse function
    }

    // return parse number
  }
}
