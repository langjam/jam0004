import { BaseType, CCType, typename } from "./types";
import {Expr, JSValue, Token} from "./expression";

export interface Stream {
  next () : Promise<string | null>;
  peek () : Promise<string | null>;
  close() : void;
}

export interface Output {
  log (text: string): Promise<void>
  out (o: any): Promise<void>
  err (e: any) : Promise<void>
}

const UNREACHABLE = -999;
const EOF_STREAM = 1000;
const PARSE_ERROR = 1001;
const RUNTIME_ERROR = 1002;

export async function interpret(src: Stream, output: Output) {
  const interpreter = new Interpreter(src, output);
  await interpreter.run();
}

class Interpreter {
  parser: Parser
  constructor (private src: Stream, private output: Output) {
    this.parser = new Parser(src, output);
  }

  log(text: string): Promise<void> {
    return this.output.log(text);
  }

  async run() {
    try {
      let finished = false;
      this.log("Welcome to the call center interpreter!");
      do {
        finished = await this.runLine();
      } while (!finished);

    } catch (e) {
      if (e === EOF_STREAM) {
        await this.log("Call ended abruptly. Thank you for using the call center interpreter!");
      } else {
        await this.output.err(e);
      }
    } finally {
      this.src.close();
    }
  }

  async runLine() : Promise<boolean>{

    this.log("To define a function, press 1. To define a type, press 2.\nTo evaluate an expression, press 3. To end the call, press 0.");

    let instr = await this.parser.next();

    switch(instr) {
      case "1":
        // define function

      break;
      case "2":
        // define type
      break;
      case "3":  // eval expression
        {
          await this.log("Please input your expression.");
          await this.interpretExpression()
        }
      break;
      case "0":
        await this.log("Thank you for using the call center interpreter!");
        return true
      default:
        await this.log("Sorry, that option is invalid.");
    }

    return false;
  }

  async interpretExpression() {
    let fullyParsed = false;
    try{
      this.parser.resetCursor();
      let expr = await this.parser.parseExpression();
      fullyParsed = true;
      await this.parser.consumeHash();

      let value = await this.visitExpr(expr);

      if (value != null) {
        this.log("The expression is evaluated to: ");
        this.output.out(value); // TODO: format this
      }

    } catch (e) {
      // TODO: handle runtime error

      switch (e) {
        case PARSE_ERROR: {
          if (fullyParsed) {
            this.parser.next();
            return;
          }

          // recover to the next nearest '#'
          while (await this.parser.peek() !== "#") {
            await this.parser.next();
          }
          await this.parser.next();

        } break;
        case RUNTIME_ERROR: {

        } break;
        default: throw e;
      }
    }
  }

  async runtimeError(message: string) {
    await this.output.err("Sorry, we found a runtime error: " + message);
    throw RUNTIME_ERROR;
  }

  async visitExpr (expr: Expr) : Promise<JSValue> {
    switch (expr.kind) {
      case Token.NUMBER: return expr.number;

      case Token.ADD:
        return (await this.visitExprAsNumber(expr.left)) + (await this.visitExprAsNumber(expr.right));
      case Token.SUB:
        return (await this.visitExprAsNumber(expr.left)) - (await this.visitExprAsNumber(expr.right));
      case Token.MUL:
        return (await this.visitExprAsNumber(expr.left)) * (await this.visitExprAsNumber(expr.right));
      case Token.DIV: {
        let leftval = await this.visitExprAsNumber(expr.left);
        let rightval = await await this.visitExprAsNumber(expr.right);

        if (rightval === 0) {
          await this.runtimeError("division by zero");
        }

        let value = leftval / rightval;
        if (expr.type === BaseType.Int) {
          value = Math.floor(value);
        }

        return value;
      }

      case Token.MOD: {
        let leftval = await this.visitExprAsNumber(expr.left);
        let rightval = await await this.visitExprAsNumber(expr.right);

        if (rightval === 0) {
          await this.runtimeError("division by zero");
        }

        return leftval % rightval;
      }
    }

    // TODO:
    return null;
  }

  async visitExprAsNumber (expr: Expr) : Promise<number> {
    return await this.visitExpr(expr) as number;
  }
}

class Parser{
  cursor: number
  constructor(private src: Stream, private output: Output) {
    this.cursor = 0;
  }

  resetCursor() {
    this.cursor = 0;
  }

  async next() : Promise<string> {
    await this.peek();

    let c = await this.src.next();
    if (!c) throw EOF_STREAM;

    this.cursor++;

    return c;
  }

  async peek() : Promise<string> {
    for(;;) {
      let c = await this.src.peek();
      if (!c) throw EOF_STREAM;


      if (/[0-9\*\#]/.test(c)) return c;

      await this.src.next();
    }
  }

  async parseError(message: string) {
    await this.output.err(`Sorry, we found an error at character ${this.cursor+1} while parsing: ${message}`);
    throw PARSE_ERROR;
  }

  async parseExpression() : Promise<Expr> {
    if (await this.peek() === '*') {
      return this.parseInstruction();
    }

    return this.parseNumber();
  }

  async parseInstruction() : Promise<Expr> {
    await this.consumeStar();

    let instrTok = await this.consumeNumber();

    if (instrTok.startsWith(Token.GETVAR.toString())) {
      // parse get variable
    } else if (instrTok.startsWith(Token.FUNCALL.toString())) {
      // parse direct call
    }

    let instr = parseInt(instrTok, 10);

    switch(instr) {
      case Token.ADD:
      case Token.SUB:
      case Token.MUL:
      case Token.DIV:
      case Token.MOD:
        return this.parseBinaryMath(instr);
      break;
    }

    await this.parseError(`Unknown instruction ${instrTok}`);
    throw UNREACHABLE;
  }

  async parseBinaryMath(operator: Expr.BinaryMathToken) : Promise<Expr> {
    await this.consumeStar();
    let left = await this.parseExpression();
    await this.consumeStar();
    let right = await this.parseExpression();

    let type = BaseType.None;

    switch (left.type){
      case BaseType.Int:
        switch (right.type){
          case BaseType.Int: type = BaseType.Int; break;
          case BaseType.Float: type = BaseType.Float; break;
        }
      break;
      case BaseType.Float:
        switch (right.type){
          case BaseType.Int: type = BaseType.Float; break;
          case BaseType.Float: type = BaseType.Float; break;
        }
      break;
    }

    if (type === BaseType.None) {
      await this.parseError(`can't do math operation between ${typename(left.type)} and ${typename(right.type)}`);
    }

    return new Expr.BinaryMath(operator, type, left, right);
  }

  async parseNumber() : Promise<Expr> {
    let number = parseInt(await this.consumeNumber(), 10);
    return new Expr.NumberExpr(number);
  }

  async consumeStar() {
    if (await this.peek() !== "*") {
      await this.parseError("expected asterisk.");
    }

    await this.next();
  }

  async consumeHash() {
    if (await this.peek() !== "#") {
      await this.parseError("expected hash at the end of declaration.");
    }

    await this.next();
  }

  async consumeNumber() : Promise<string> {
    let numbers = [];

    while (/[0-9]/.test(await this.peek())) {
      numbers.push(await this.next());
    }

    if (numbers.length === 0) {
      await this.parseError("expected number.");
    }

    return numbers.join("");
  }
}
