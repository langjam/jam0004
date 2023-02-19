import { BaseType, CCType } from "./types";

export type JSValue = number | boolean | string | Function | JSValue[] | null;

export class Value {
  constructor(public type: CCType, value: JSValue){}
}

interface ExprLike {
  kind: Token
  type: CCType
}

export enum Token {
  // BINARY
  // I/F -> I/F -> I/F
  ADD = 233,
  SUB = 782,
  MUL = 685,
  DIV = 348,
  MOD = 663,

  // Eq(a) => a -> a -> Bool
  // Eq(a) : Int, Float, Bool, String, List a, None, Tuple (a...), Option (a...) (anything except function)
  EQ = 37,
  NE = 63,
  LT = 58,
  GT = 48,
  LTE = 583,
  GTE = 483,

  // bool -> bool -> bool
  AND = 263,
  OR = 67,

  // UNARY
  INT = 468, // float -> int
  FLO = 356, // int -> float
  STR = 787, // str any

  NEG = 634, // int | float -> int | float

  NOT = 668, // bool -> bool

  // LIST
  // a [a] -> [a] | [a] a -> [a] | [a] -> [a] -> [a]
  // int string -> string | string int -> string | string string -> string

  APP = 277, // app a [a] / [a] a / [a] [a]

  LIST = 5478, // *LIST * nn * a * a * a * ...

  // string | [a], int -> string | a
  GET = 438, // get list index

  // string | [a], int, int | string | a -> string | [a]
  SET = 738, // set list index value

  // string | [a] -> int
  LEN = 536, // len list

  // string | [a], int -> string | [a]
  REM = 736, // rem list index

  CHRS = 2488, // [int] -> str

  // tuple
  TUP = 887, // TUP * nn e e ...
  TGET = 8438, // 8438 * nn tuple int
  TSET = 8738, // 8738 * nn tuple int e

  IF = 43, // if * c * t * f
  IFL = 435, // ifl * nn * ty * e * et * ef

  GETVAR = 0, // *0nn,
  FUNCALL = 1, // *1nnn direct call
  LET = 538, // *LET * nn * v * e
  CALL = 2255, // *call * nn * e * param...

  NUMBER = -1
}

export type Expr = Expr.NumberExpr | Expr.BinaryMath | Expr.Comparison | Expr.LogicCircuit | Expr.TypeConversion;

export namespace Expr {
  export class NumberExpr implements ExprLike {
    kind: Token.NUMBER = Token.NUMBER;
    type: CCType = BaseType.Int;

    constructor(public number: number) {}
  }

  export type BinaryMathToken = Token.ADD | Token.SUB | Token.MUL | Token.DIV | Token.MOD;

  export class BinaryMath implements ExprLike {
    constructor(public kind: BinaryMathToken, public type: CCType, public left: Expr, public right: Expr) {}
  }

  export type CompareToken = Token.EQ | Token.NE | Token.LT | Token.GT | Token.LTE | Token.GTE;

  export class Comparison implements ExprLike {
    type: CCType = BaseType.Bool;

    constructor(public kind: CompareToken, public left: Expr, public right: Expr) {}
  }

  export class LogicCircuit implements ExprLike {
    type: CCType = BaseType.Bool;
    constructor(public kind: Token.AND | Token.OR, public left: Expr, public right: Expr) {}
  }

  export type ConversionToken = Token.INT | Token.FLO | Token.STR;
  export class TypeConversion implements ExprLike {
    constructor(public kind: ConversionToken, public type: CCType, public expr: Expr) {}
  }
}
