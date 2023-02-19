import { BaseType, CCType, coversType, FunctionType, isBaseType, isFunctionType, isTypeEqual, ListType, OptionType, TupleType, TypeKind, typename } from "./types";
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

const EOF_STREAM = 1000;
const PARSE_ERROR = 1001;
const RUNTIME_ERROR = 1002;

function unreachable() : Error {
  return new Error("unreachable");
}

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

      // math ops
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

      // comparison
      case Token.EQ: {
        let leftval = await this.visitExpr(expr.left);
        let rightval = await this.visitExpr(expr.right);

        let compared = compare(leftval as ComparableTypes, rightval as ComparableTypes);
        return compared === 0;
      }
      case Token.NE: {
        let leftval = await this.visitExpr(expr.left);
        let rightval = await this.visitExpr(expr.right);

        let compared = compare(leftval as ComparableTypes, rightval as ComparableTypes);
        return compared !== 0;
      }
      case Token.LT: {
        let leftval = await this.visitExpr(expr.left);
        let rightval = await this.visitExpr(expr.right);

        let compared = compare(leftval as ComparableTypes, rightval as ComparableTypes);
        return compared < 0;
      }
      case Token.GT: {
        let leftval = await this.visitExpr(expr.left);
        let rightval = await this.visitExpr(expr.right);

        let compared = compare(leftval as ComparableTypes, rightval as ComparableTypes);
        return compared > 0;
      }
      case Token.LTE: {
        let leftval = await this.visitExpr(expr.left);
        let rightval = await this.visitExpr(expr.right);

        let compared = compare(leftval as ComparableTypes, rightval as ComparableTypes);
        return compared <= 0;
      }
      case Token.GTE: {
        let leftval = await this.visitExpr(expr.left);
        let rightval = await this.visitExpr(expr.right);

        let compared = compare(leftval as ComparableTypes, rightval as ComparableTypes);
        return compared >= 0;
      }

      // logic circuit
      case Token.AND:
      case Token.OR: {
        let leftval = await this.visitExprAsBool(expr.left);
        if (expr.kind === Token.AND && !leftval) return false;
        if (expr.kind === Token.OR && leftval) return true;

        return await this.visitExprAsBool(expr.right);
      }

      // type conversion
      case Token.INT:
      case Token.FLO: {
        let val = await this.visitExprAsNumber(expr.expr);
        return val;
      }

      case Token.STR: {
        let val = await this.visitExpr(expr.expr);
        return stringify(val);
      }

      case Token.NOT: {
        let val = await this.visitExprAsBool(expr.expr);
        return !val;
      }

      case Token.NEG: {
        let val = await this.visitExprAsNumber(expr.expr);
        return -val;
      }

      case Token.LIST: {
        let values = [];

        for (let element of expr.elements) {
          values.push(await this.visitExpr(element));
        }

        return values;
      }
    }

    // TODO:
    return null;
  }

  async visitExprAsNumber (expr: Expr) : Promise<number> {
    return await this.visitExpr(expr) as number;
  }

  async visitExprAsBool (expr: Expr) : Promise<boolean> {
    return await this.visitExpr(expr) as boolean;
  }
}

function stringify(t: JSValue) : string {
  if (t == null) return "None";
  return t.toString();
}

type ComparableBase = number | boolean | string
type ComparableTypes =  ComparableBase | null | ComparableTypes[];

function compare (a: ComparableTypes, b: ComparableTypes) : number {
  if (Array.isArray(a)) {
    return compareList(a as ComparableTypes[], b as ComparableTypes[]);
  }

  return compareBase(a as ComparableBase, b as ComparableBase);
}

function compareBase(a: ComparableBase | null, b: ComparableBase | null) : number {
  if (a == null) return 0;
  let ax = a as ComparableBase;
  let bx = b as ComparableBase;

  if (ax < bx) return -1;
  else if (ax > bx) return 1;
  else return 0;
}

function compareList(a: ComparableTypes[], b: ComparableTypes[]) : number {
  const n = Math.min(a.length, b.length);

  for (let i = 0; i < n; i++) {
    if (Array.isArray(a[i])) {
      let compared = compareList(a[i] as ComparableTypes[], b[i] as ComparableTypes[]);
      if (compared !== 0) return compared;
    } else {
      let compared = compareBase(a[i] as ComparableBase, b[i] as ComparableBase);
      if (compared !== 0) return compared;
    }
  }

  if (a.length < b.length) {
    return -1;
  } else if (a.length > b.length) {
    return 1;
  } else {
    return 0;
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

  async parseError(message: string, pos?: number) {
    if (pos != null) {
      this.cursor = pos;
    }

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

      case Token.EQ:
      case Token.NE:
      case Token.LT:
      case Token.GT:
      case Token.LTE:
      case Token.GTE:
        return this.parseCompare(instr);

      case Token.AND:
      case Token.OR:
        return this.parseLogic(instr);

      case Token.INT:
      case Token.FLO:
      case Token.STR:
        return this.parseConversion(instr);

      case Token.NEG:
      case Token.NOT:
        return this.parseUnary(instr);

      case Token.LIST:
        return this.parseListCons();
    }

    await this.parseError(`unknown instruction ${instrTok}`);
    throw unreachable();
  }

  // type expression
  async parseType() : Promise<CCType> {
    let token = await this.consumeDigit();

    switch (token) {
      case TypeKind.Int: return BaseType.Int;
      case TypeKind.Float: return BaseType.Float;
      case TypeKind.Bool: return BaseType.Bool;
      case TypeKind.String: return BaseType.String;
      case TypeKind.None: return BaseType.None;

      case TypeKind.List: return this.parseTypeList();
      case TypeKind.Tuple: return this.parseTypeTuple();
      case TypeKind.Option: return this.parseTypeOption();

      case TypeKind.Function: return this.parseTypeFunction();
      case TypeKind.Custom: return this.parseTypeCustom();
    }

    throw unreachable();
  }

  async parseTypeList() : Promise<CCType> {
    let elementType = await this.parseType();
    return new ListType(elementType);
  }

  async parseTypeTuple() : Promise<CCType> {
    let startPos = this.cursor;
    let tens = await this.consumeDigit();
    let units = await this.consumeDigit();
    let n = tens * 10 + units;

    if (n < 2) {
      await this.parseError("tuple must have at least 2 element types.", startPos);
    }

    let types : CCType[] = [];
    for (let i = 0; i < n; i++) {
      types.push(await this.parseType());
    }

    return new TupleType(types);
  }

  async parseTypeOption() : Promise<CCType> {
    let startPos = this.cursor;
    let tens = await this.consumeDigit();
    let units = await this.consumeDigit();
    let n = tens * 10 + units;

    if (n < 2) {
      await this.parseError("options must have at least 2 choice types.", startPos);
    }

    let types : CCType[] = [];
    for (let i = 0; i < n; i++) {
      types.push(await this.parseType());
    }

    return new OptionType(types);
  }

  async parseTypeFunction() : Promise<CCType> {
    let tens = await this.consumeDigit();
    let units = await this.consumeDigit();
    let n = tens * 10 + units;

    let paramTypes : CCType[] = [];
    for (let i = 0; i < n; i++) {
      paramTypes.push(await this.parseType());
    }

    let returnType = await this.parseType();

    return new FunctionType(returnType, paramTypes);
  }

  async parseTypeCustom() : Promise<CCType> {
    //TODO: resolve custom type
    return BaseType.None
  }

  // expression

  async parseListCons() : Promise<Expr> {
    await this.consumeStar();
    let elementType = await this.parseType();
    await this.consumeStar();
    let numArgs = parseInt(await this.consumeNumber(), 10) || 0;

    let startPos = this.cursor;
    let elements = await this.parseArgs(numArgs);

    // typecheck
    for (let element of elements) {
      if (!coversType(elementType, element.type)) {
        await this.parseError(`type ${typename(element.type)} is not assignable to list of element type ${typename(elementType)}`, startPos);
      }
    }

    return new Expr.ListCons(new ListType(elementType), elements);
  }

  async parseArgs(n: number) : Promise<Expr[]> {
    let args = [];
    for (let i = 0; i < n; i++) {
      await this.consumeStar();
      args.push(await this.parseExpression());
    }

    return args;
  }

  async parseBinaryMath(operator: Expr.BinaryMathToken) : Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
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
      await this.parseError(`unable to do math operation between types ${typename(left.type)} and ${typename(right.type)}`, startPos);
    }

    return new Expr.BinaryMath(operator, type, left, right);
  }

  async parseCompare(operator: Expr.CompareToken) : Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let left = await this.parseExpression();
    await this.consumeStar();
    let right = await this.parseExpression();

    // type check
    if (isFunctionType(left.type) || isFunctionType(right.type) || !isTypeEqual(left.type, right.type)) {
      await this.parseError(`unable to do comparison between types ${typename(left.type)} and ${typename(right.type)}`, startPos);
    }

    return new Expr.Comparison(operator, left, right);
  }

  async parseLogic(operator: Token.AND | Token.OR): Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let left = await this.parseExpression();
    await this.consumeStar();
    let right = await this.parseExpression();

    if (left.type !== BaseType.Bool || right.type !== BaseType.Bool) {
      await this.parseError(`unable to do logic operator between types ${typename(left.type)} and ${typename(right.type)}`, startPos);
    }

    return new Expr.LogicCircuit(operator, left, right);
  }

  async parseConversion(operator: Expr.ConversionToken): Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let expr = await this.parseExpression();

    let type = BaseType.None;
    let target = BaseType.None;
    switch (operator) {
      case Token.INT: {
        target = BaseType.Int;
        if (expr.type === BaseType.Float) type = target;
      } break;
      case Token.FLO: {
        target = BaseType.Float;
        if (expr.type === BaseType.Int) type = target;
      } break;
      case Token.STR: {
        target = BaseType.String;
        type = target;
      }
    }

    if (type === BaseType.None) {
      await this.parseError(`unable to do conversion from type ${typename(expr.type)} into ${typename(target)}`, startPos);
    }

    return new Expr.TypeConversion(operator, type, expr);
  }

  async parseUnary(operation: Expr.UnaryToken): Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let expr = await this.parseExpression();

    let type = BaseType.None
    if (operation === Token.NEG && (expr.type === BaseType.Int || expr.type === BaseType.Float)) {
      type = expr.type;
    } else if (operation === Token.NOT && expr.type === BaseType.Bool) {
      type = BaseType.Bool;
    }

    if (type === BaseType.None) {
      await this.parseError(`invalid operation for type ${typename(expr.type)}`, startPos);
    }

    return new Expr.Unary(operation, type, expr);
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

  async consumeDigit() : Promise<number> {
    if (!/[0-9]/.test(await this.peek())) {
      await this.parseError("expected digit.");
    }

    return parseInt(await this.next(), 10);
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
