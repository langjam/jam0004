import { BaseType, CCType, coversType, FunctionType, isBaseType, isFunctionType, isListType, isOptionType, isTupleType, isTypeEqual, ListType, NonOptionType, OptionType, TupleType, TypeKind, typename } from "./types";
import {Expr, FunctionObj, JSNonOption, JSValue, OptionVal, stringify, Token} from "./expression";

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

class Environment {
  vars: Map<number, [CCType, JSValue]>
  funcs: Map<number, FunctionObj>
  types: Map<number, CCType>
  constructor(public parent?: Environment) {
    this.vars = new Map();
    this.funcs = new Map();
    this.types = new Map();
  }

  getVar(name: number): [CCType, JSValue] | undefined {
    let local = this.vars.get(name);
    if (local) return local;

    if (this.parent) return this.parent.getVar(name);
  }

  setVar(name: number, type: CCType, value: JSValue) {
    this.vars.set(name, [type, value]);
  }

  getFunc(name: number) : FunctionObj | undefined {
    let local = this.funcs.get(name);
    if (local) return local;

    if (this.parent) return this.parent.getFunc(name);
  }

  setFunc(name: number, func: FunctionObj) {
    this.funcs.set(name, func);
  }

  getType(name: number) : CCType | undefined {
    let local = this.types.get(name);
    if (local) return local;

    if (this.parent) return this.parent.getType(name);
  }

  setType(name: number, type: CCType) {
    this.types.set(name, type);
  }
}

class Interpreter {
  parser: Parser
  env: Environment

  constructor (private src: Stream, private output: Output) {
    this.env = new Environment();
    this.parser = new Parser(src, output, this.env);
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
        {
          await this.log("Please input your function definition.");
          await this.interpretFunctionDef();
        }
      break;
      case "2":
        await this.log("Please input your type definition.");
        await this.interpretTypeDef();
      break;
      case "3":
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
        this.output.out(print(value));
      }

    } catch (e) {
      this.handleError(fullyParsed, e);
    }
  }

  async interpretFunctionDef() {
    let fullyParsed = false;
    try{
      this.parser.resetCursor();
      await this.parser.parseFunctionDefinition();
      fullyParsed = true;

      await this.parser.consumeHash();

      this.log("Function is now declared.");
    } catch (e) {
      this.handleError(fullyParsed, e);
    }
  }

  async interpretTypeDef() {
    let fullyParsed = false;
    try{
      this.parser.resetCursor();
      await this.parser.parseTypeDefinition();
      fullyParsed = true;

      await this.parser.consumeHash();

      this.log("Type is now declared.");
    } catch (e) {
      this.handleError(fullyParsed, e);
    }
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

      case Token.APP: {
        let leftval = await this.visitExpr(expr.left);
        let rightval = await this.visitExpr(expr.right);

        if (isListType(expr.left.type)) {
          if (isListType(expr.right.type)) {
            return (leftval as JSValue[]).concat(rightval as JSValue[]);
          }

          (leftval as JSValue[]).push(rightval);
          return leftval;
        }

        // right must be a list
        (rightval as JSValue[]).unshift(leftval);
        return rightval;
      }

      case Token.SAPP: {
        let leftval = await this.visitExpr(expr.left);
        let rightval = await this.visitExpr(expr.right);

        if (expr.left.type === BaseType.Int) {
          leftval = String.fromCharCode((leftval as number) % 256);
        } else if (expr.right.type === BaseType.Int) {
          rightval = String.fromCharCode((rightval as number) % 256);
        }

        return (leftval as string) + (rightval as string);
      }

      case Token.GET:
      case Token.SGET:
      case Token.TGET: {
        let listval = (await this.visitExpr(expr.list)) as JSValue[];
        let index = await this.visitExprAsNumber(expr.index);

        if (index < 0 || index >= listval.length) {
          await this.runtimeError("index out of bound");
        }

        return listval[index];
      }

      case Token.SET:
      case Token.TSET: {
        let listval = (await this.visitExpr(expr.list)) as JSValue[];
        let index = await this.visitExprAsNumber(expr.index);
        let value = await this.visitExpr(expr.value);

        if (index < 0 || index >= listval.length) {
          await this.runtimeError("index out of bound");
        }

        listval[index] = value;
        return listval;
      }

      case Token.SSET: {
        let strval = (await this.visitExpr(expr.list)) as string;
        let index = await this.visitExprAsNumber(expr.index);
        let value = await this.visitExpr(expr.value);

        if (index < 0 || index >= strval.length) {
          await this.runtimeError("index out of bound");
        }

        if (expr.value.type === BaseType.Int) {
          value = String.fromCharCode(value as number);
        }

        return strval.substring(0, index) + (value as string)[0] + strval.substring(index + 1);
      }

      case Token.LEN: {
        let listval = (await this.visitExpr(expr.value)) as JSValue[];
        return listval.length;
      }

      case Token.CHRS: {
        let listval = (await this.visitExpr(expr.value)) as number[];
        return listval.map(c => String.fromCharCode(c)).join("");
      }

      case Token.TUP: {
        let values = [];

        for (let value of expr.values) {
          values.push(await this.visitExpr(value));
        }

        return values;
      }

      case Token.IF: {
        let cond = await this.visitExprAsBool(expr.cond);
        let toVisit = cond ? expr.trueVal : expr.falseVal;

        return await this.visitExpr(toVisit);
      }

      case Token.FUNCALL: {
        let parentEnv = this.env;
        let funcEnv = new Environment(parentEnv);

        for (let i = 0; i < expr.args.length; i++) {
          let arg = expr.args[i];
          let value = await this.visitExpr(arg);
          funcEnv.setVar(i, arg.type, value);
        }

        try {
          this.env = funcEnv;
          return await this.visitExpr(expr.func.body);
        } finally {
          this.env = parentEnv;
        }
      }

      case Token.GETVAR: {
        let vardata = this.env.getVar(expr.id);

        if (!vardata) {
          // it shouldnt be possible, but just in case
          await this.runtimeError(`Missing variable #${expr.id}`)
          throw unreachable();
        }

        return vardata[1];
      }

      case Token.LET: {
        let value = await this.visitExpr(expr.value);

        let parentEnv = this.env;
        let letEnv = new Environment(parentEnv);

        letEnv.setVar(expr.id, expr.value.type, value);

        try{
          this.env = letEnv;
          return await this.visitExpr(expr.inExpr);
        } finally {
          this.env = parentEnv;
        }
      }

      case Token.TRANSFORM_OPT: {
        let value = await this.visitExpr(expr.value) as JSNonOption;
        return new OptionVal(expr.type, expr.originalType, value);
      }

      case Token.IFL: {
        let value = await this.visitExpr(expr.value);

        if (!(value instanceof OptionVal)) {
          // should not be possible
          await this.runtimeError("option value corrupted");
          throw unreachable();
        }

        if (!coversType(expr.convertType, value.originalType)) {
          return await this.visitExpr(expr.falseVal);
        }

        if (isOptionType(expr.convertType)) {
          value = new OptionVal(expr.convertType, value.originalType, value.value);
        } else {
          value = value.value;
        }

        let parentEnv = this.env;
        let ifletEnv = new Environment(parentEnv);

        ifletEnv.setVar(expr.id, expr.convertType, value);

        try{
          this.env = ifletEnv;
          return await this.visitExpr(expr.trueVal);
        } finally {
          this.env = parentEnv;
        }
      }
    }

    throw unreachable();
  }

  async visitExprAsNumber (expr: Expr) : Promise<number> {
    return await this.visitExpr(expr) as number;
  }

  async visitExprAsBool (expr: Expr) : Promise<boolean> {
    return await this.visitExpr(expr) as boolean;
  }

  async handleError(fullyParsed: boolean, e: any) {
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

  async runtimeError(message: string) {
    await this.output.err("Sorry, we found a runtime error: " + message);
    throw RUNTIME_ERROR;
  }
}


export function print(t: JSValue) : string {
  if (typeof t === "string") return `"${t}"`;
  if (t instanceof OptionVal) return print(t.value);
  if (Array.isArray(t)) {
    let str = t.map(print).join(",")
    return `[${str}]`;
  }

  return stringify(t);
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
  constructor(private src: Stream, private output: Output, private env: Environment) {
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

  // definitions

  // type expression
  async parseTypeDefinition() {
    // * type 1nnn * type
    await this.consumeStar();
    let startpos = this.cursor;

    let n = await this.consumeDigit();
    if (n !== 1) await this.parseError("Custom type must start with 1", startpos);

    let hundreds = await this.consumeDigit();
    let tens = await this.consumeDigit();
    let units = await this.consumeDigit();

    let id = 1000 + hundreds*100 + tens*10 + units;

    await this.consumeStar();
    let aliasType = await this.parseType();
    this.env.setType(id, aliasType);
  }

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
    let hundreds = await this.consumeDigit();
    let tens = await this.consumeDigit();
    let units = await this.consumeDigit();

    let id = 1000 + hundreds*100 + tens*10 + units;

    let type = this.env.getType(id);
    if (type == null) {
      await this.parseError(`unknown declared type with id ${type}.`);
      throw unreachable();
    }

    return type;
  }

  // function

  async parseFunctionDefinition() {
    // * id * num_param * type1 * type2 * ... * ret_type * e

    await this.consumeStar();
    let id = parseInt(await this.consumeNumber(), 10);

    await this.consumeStar();
    let startpos = this.cursor;
    let numParams = parseInt(await this.consumeNumber(), 10);

    if (numParams > 99) {
      await this.parseError("Function can only have at max 99 paramters.", startpos);
    }

    let paramTypes : CCType[] = [];
    for (let i = 0; i < numParams; i++) {
      await this.consumeStar();
      paramTypes.push(await this.parseType());
    }

    await this.consumeStar();
    let returnType = await this.parseType();

    let funcType = new FunctionType(returnType, paramTypes);
    let func = new FunctionObj(id, funcType, new Expr.NumberExpr(0)) // dummy expr

    let parentEnv = this.env;
    let tempEnv = new Environment(parentEnv);

    tempEnv.setFunc(id, func);
    for (let i = 0; i < numParams; i++) {
      tempEnv.setVar(i, paramTypes[i], null); // dummy js value
    }

    try {
      this.env = tempEnv;

      await this.consumeStar();
      startpos = this.cursor;
      let body = await this.parseExpression();

      if (!coversType(returnType, body.type)) {
        await this.parseError(`unable to assign type ${typename(body.type)} for return type ${typename(returnType)}.`);
      }

      body = this.transformOpt(returnType, body);

      func.body = body;

      // add to parent (which should be global env) when all is successful
      parentEnv.setFunc(id, func);
    } finally {
      this.env = parentEnv;
    }
  }

  // expressions

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
      return this.parseGetVar(instrTok);
    } else if (instrTok.startsWith(Token.FUNCALL.toString())) {
      return this.parseFunCall(instrTok);
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

      case Token.APP:
        return this.parseAppend();

      case Token.GET:
        return this.parseLSGet();

      case Token.SET:
        return this.parseLSSet();

      case Token.LEN:
        return this.parseLen();

      case Token.CHRS:
        return this.parseChrs();

      case Token.TUP:
        return this.parseTup();

      case Token.TGET:
        return this.parseTget();

      case Token.TSET:
        return this.parseTset();

      case Token.IF:
        return this.parseIf();

      case Token.LET:
        return this.parseLet();

      case Token.IFL:
        return this.parseIfLet();
    }

    await this.parseError(`unknown instruction ${instrTok}`);
    throw unreachable();
  }

  // expression

  // control & call

  async parseIf() : Promise<Expr> {
    // if * c * t * f
    await this.consumeStar();
    let startpos = this.cursor;
    let cond = await this.parseExpression();

    if (cond.type !== BaseType.Bool) {
      await this.parseError(`invalid type ${typename(cond.type)} for if condition expression.`, startpos);
    }

    await this.consumeStar();
    let trueExpr = await this.parseExpression();

    await this.consumeStar();
    let falseExpr = await this.parseExpression();

    let type = trueExpr.type;
    if (!isTypeEqual(trueExpr.type, falseExpr.type)) {
      type = new OptionType([trueExpr.type, falseExpr.type]);
    }

    return new Expr.IfExpr(type, cond, trueExpr, falseExpr);
  }

  async parseFunCall(token: string) : Promise<Expr> {
    // *1nnn * e1 * e2 * ...
    let startpos = this.cursor - token.length;
    if (token.length < 2) {
      await this.parseError("invalid function call format.", startpos);
    }

    let id = parseInt(token.slice(1), 10);
    let func = this.env.getFunc(id);

    if (!func) {
      await this.parseError(`unknown function with id ${id}`, startpos + 1);
      throw unreachable();
    }

    startpos = this.cursor;
    let numParams = func.type.paramTypes.length;
    let args = await this.parseArgs(numParams);

    // typecheck
    for (let i = 0; i < numParams; i++) {
      let parType = func.type.paramTypes[i];
      let arg = args[i];
      if (!coversType(parType, arg.type)) {
        await this.parseError(`unable to assign argument with type ${typename(arg.type)} to parameter of type ${typename(parType)}`, startpos);
      }

      args[i] = this.transformOpt(parType, arg);
    }

    return new Expr.FunCall(func.type.returnType, func, args);
  }

  async parseGetVar(token: string) : Promise<Expr> {
    // *0nnn
    let startpos = this.cursor - token.length;
    if (token.length < 2) {
      await this.parseError("invalid get var format.", startpos);
    }

    let id = parseInt(token.slice(1), 10);
    let vardata = this.env.getVar(id);

    if (!vardata) {
      await this.parseError(`unknown function with id ${id}`, startpos + 1);
      throw unreachable();
    }

    let type = vardata[0];

    return new Expr.GetVar(type, id);
  }

  async parseLet() : Promise<Expr> {
    // *LET * nn * v * e
    await this.consumeStar();
    let id = parseInt(await this.consumeNumber(), 10);

    await this.consumeStar();
    let value = await this.parseExpression();

    let parentEnv = this.env;
    let tempEnv = new Environment(parentEnv);

    tempEnv.setVar(id, value.type, null); // dummy variable

    try {
      this.env = tempEnv;
      await this.consumeStar();
      let inExpr = await this.parseExpression();

      return new Expr.Let(inExpr.type, id, value, inExpr);
    } finally {
      this.env = parentEnv;
    }
  }

  async parseIfLet() : Promise<Expr> {
    // ifl * nn * ty * e * et * ef
    await this.consumeStar();
    let id = parseInt(await this.consumeNumber(), 10);

    await this.consumeStar();
    let convertType = await this.parseType();

    await this.consumeStar();
    let startpos = this.cursor;
    let value = await this.parseExpression();

    if (!isOptionType(value.type)) {
      await this.parseError(`invalid use of iflet from value of type ${typename(value.type)} instead of an option type.`, startpos);
    } else if (!coversType(value.type, convertType)) { // the reverse of the usual
      await this.parseError(`unable to derive type ${typename(convertType)} from ${typename(value.type)}.`, startpos);
    }

    let parentEnv = this.env;
    let tempEnv = new Environment(parentEnv);

    tempEnv.setVar(id, convertType, null); // dummy variable

    let trueVal: Expr;

    try {
      this.env = tempEnv;
      await this.consumeStar();
      trueVal = await this.parseExpression();
    } finally {
      this.env = parentEnv;
    }

    await this.consumeStar();
    let falseVal = await this.parseExpression();

    let type = trueVal.type;
    if (!isTypeEqual(trueVal.type, falseVal.type)) {
      type = new OptionType([trueVal.type, falseVal.type]);
    }

    return new Expr.IfLet(type, id, convertType, value, trueVal, falseVal);
  }

  // tuple
  async parseTup() : Promise<Expr> {
    // TUP * nn e e ...
    await this.consumeStar();
    let startpos = this.cursor;
    let numArgs = parseInt(await this.consumeNumber(), 10) || 0;

    if (numArgs < 2 || numArgs > 99) {
      await this.parseError("tuple size must be between 2-99 elements.", startpos);
    }

    let elements = await this.parseArgs(numArgs);
    let tupleType = new TupleType(elements.map(e => e.type));

    return new Expr.Tuple(tupleType, elements);
  }

  async parseTget() : Promise<Expr> {
    // tget tuple nn
    await this.consumeStar();
    let startPos = this.cursor;
    let tuple = await this.parseExpression();

    if (!isTupleType(tuple.type)) {
      await this.parseError(`unable to do tuple get operation for type ${typename(tuple.type)}`, startPos);
      throw unreachable();
    }

    await this.consumeStar();
    startPos = this.cursor;
    let index = parseInt(await this.consumeNumber(), 10);

    if (index < 0 || index >= tuple.type.productTypes.length) {
      await this.parseError(`invalid tuple index ${index}`, startPos);
    }

    let type = tuple.type.productTypes[index];
    let indexExpr = new Expr.NumberExpr(index);

    return new Expr.Get(Token.TGET, type, tuple, indexExpr);
  }

  async parseTset() : Promise<Expr> {
    // tset tuple nn value
    await this.consumeStar();
    let startPos = this.cursor;
    let tuple = await this.parseExpression();

    if (!isTupleType(tuple.type)) {
      await this.parseError(`unable to do tuple get operation for type ${typename(tuple.type)}`, startPos);
      throw unreachable();
    }

    await this.consumeStar();
    startPos = this.cursor;
    let index = parseInt(await this.consumeNumber(), 10);

    if (index < 0 || index >= tuple.type.productTypes.length) {
      await this.parseError(`invalid tuple index ${index}`, startPos);
    }

    let elementType = tuple.type.productTypes[index];

    await this.consumeStar();
    startPos = this.cursor;
    let value = await this.parseExpression();

    if (!coversType(elementType, value.type)) {
      await this.parseError(`unable to do set tuple operation between types ${typename(elementType)} and ${typename(value.type)}.`);
    }

    value = this.transformOpt(elementType, value);

    let indexExpr = new Expr.NumberExpr(index);

    return new Expr.Set(Token.TSET, tuple.type, tuple, indexExpr, value);
  }

  // list & strings
  async parseListCons() : Promise<Expr> {
    await this.consumeStar();
    let elementType = await this.parseType();
    await this.consumeStar();
    let numArgs = parseInt(await this.consumeNumber(), 10) || 0;

    let startPos = this.cursor;
    let elements = await this.parseArgs(numArgs);

    // typecheck
    for (let i = 0; i < elements.length; i++) {
      let element = elements[i];
      if (!coversType(elementType, element.type)) {
        await this.parseError(`type ${typename(element.type)} is not assignable to list of element type ${typename(elementType)}`, startPos);
      }

      elements[i] = this.transformOpt(elementType, element);
    }

    return new Expr.ListCons(new ListType(elementType), elements);
  }

  async parseAppend() : Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let left = await this.parseExpression();
    await this.consumeStar();
    let right = await this.parseExpression();

    if (isListType(left.type) || isListType(right.type)) {
      return this.parseAppendList(startPos, left, right);
    }

    return this.parseAppendStr(startPos, left, right)
  }

  async parseAppendList(startPos: number, left: Expr, right: Expr) : Promise<Expr> {
    let type : CCType = BaseType.None;

    if (isListType(left.type)) {
      if (isTypeEqual(left.type, right.type)) type = left.type;
      else if (coversType(left.type.elementType, right.type)) {
        type = left.type;
        right = this.transformOpt(type.elementType, right);
      }
    } else if (isListType(right.type)) {
      if (coversType(right.type.elementType, left.type)){
        type = right.type;
        left = this.transformOpt(type.elementType, left);
      }
    }

    if (type === BaseType.None) {
      await this.parseError(`unable to do append list operation between types ${typename(left.type)} and ${typename(right.type)}`, startPos);
    }

    return new Expr.Append(Token.APP, type, left, right);
  }

  async parseAppendStr(startPos: number, left: Expr, right: Expr) : Promise<Expr> {
    let type = BaseType.None;

    if (left.type === BaseType.String && right.type === BaseType.String) {
      type = BaseType.String;
    } else if (left.type === BaseType.String && right.type === BaseType.Int) {
      type = BaseType.String;
    } else if (left.type === BaseType.Int && right.type === BaseType.String) {
      type = BaseType.String;
    }

    if (type === BaseType.None) {
      await this.parseError(`unable to do append operation between types ${typename(left.type)} and ${typename(right.type)}`, startPos);
    }

    return new Expr.Append(Token.SAPP, type, left, right);
  }

  async parseLSGet() : Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let list = await this.parseExpression();

    await this.consumeStar();
    let idxPos = this.cursor
    let index = await this.parseExpression();

    if (index.type !== BaseType.Int) {
      await this.parseError(`index in get operation must be of type ${typename(BaseType.Int)}, instead of ${typename(index.type)}`, idxPos);
    }

    let type : CCType = BaseType.None;
    let operator = Token.GET;

    if (list.type === BaseType.String) {
      type = BaseType.String;
      operator = Token.SGET;
    } else if (isListType(list.type)) {
      type = list.type.elementType;
    }

    if (type === BaseType.None) {
      await this.parseError(`unable to do get operation for type ${typename(list.type)}`, startPos);
    }

    return new Expr.Get(operator, type, list, index);
  }

  async parseLSSet() : Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let list = await this.parseExpression();

    await this.consumeStar();
    let idxPos = this.cursor
    let index = await this.parseExpression();

    if (index.type !== BaseType.Int) {
      await this.parseError(`index in get operation must be of type ${typename(BaseType.Int)}, instead of ${typename(index.type)}`, idxPos);
    }

    await this.consumeStar();
    let value = await this.parseExpression();

    let type : CCType = BaseType.None;
    let operator = Token.SET;

    if (list.type === BaseType.String && (value.type === BaseType.String || value.type === BaseType.Int)) {
      type = BaseType.String;
      operator = Token.SSET;
    } else if (isListType(list.type) && coversType(list.type.elementType, value.type)) {
      type = list.type;
      value = this.transformOpt(type.elementType, value);
    }

    if (type === BaseType.None) {
      await this.parseError(`unable to do set operation for types ${typename(list.type)} and ${typename(value.type)}`, startPos);
    }

    return new Expr.Set(operator, type, list, index, value);
  }

  async parseLen() : Promise <Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let list = await this.parseExpression();

    if (list.type !== BaseType.String && !isListType(list.type)) {
      await this.parseError(`unable to do len operation for type ${typename(list.type)}`, startPos);
    }

    return new Expr.Len(list);
  }

  async parseChrs() : Promise<Expr> {
    await this.consumeStar();
    let startPos = this.cursor;
    let list = await this.parseExpression();

    if (isListType(list.type) && list.type.elementType === BaseType.Int) {
      return new Expr.Chrs(list);
    }

    await this.parseError(`unable to do chars operation for type ${typename(list.type)}`, startPos);
    throw unreachable();
  }

  // arguments

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

  transformOpt(target: CCType, sourceExpr: Expr) : Expr {
    // assumption: target `coversType` sourceExpr.type
    if (isOptionType(target) && !isOptionType(sourceExpr.type)) {
      return new Expr.OptTransform(target, sourceExpr.type, sourceExpr);
    }

    return sourceExpr;
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
