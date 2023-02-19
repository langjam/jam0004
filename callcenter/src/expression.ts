import { BaseType, CCType, FunctionType, ListType, NonOptionType, OptionType, TupleType } from "./types";

export type JSNonOption = number | boolean | string | Function | JSValue[] | null;
export type JSValue = JSNonOption | OptionVal;

export class OptionVal {
  constructor(public type: OptionType, public originalType: NonOptionType, public value: JSNonOption){}

  toString() : string {
    return stringify(this.value);
  }
}

export class FunctionObj {
  constructor(public name: number, public type: FunctionType, public body: Expr) {}
  toString() : string {
    return "[Function]";
  }
}

export function stringify(t: JSValue) : string {
  if (t == null) return "None";
  return t.toString();
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

  LIST = 5478, // *LIST * type * nn * a * a * a * ...

  APP = 277, // app a [a] / [a] a / [a] [a]
  SAPP = -277, // for the string version

  // string | [a], int -> string | a
  GET = 438, // get list index
  SGET = -438, // string version

  // string | [a], int, int | string | a -> string | [a]
  SET = 738, // set list index value
  SSET = -738, // string version

  // string | [a] -> int
  LEN = 536, // len list / string

  CHRS = 2488, // [int] -> str

  // tuple
  TUP = 887, // TUP * nn e e ...
  TGET = 8438, // 8438 * tuple nn
  TSET = 8738, // 8738 * tuple nn val

  IF = 43, // if * c * t * f

  // function definition
  // 1 => * number * ret_type * num_param * type1 * type2 * e

  FUNCALL = 1, // *1nnn * e1 * e2 * ...

  GETVAR = 0, // *0nn,

  LET = 538, // *LET * nn * v * e
  IFL = 435, // ifl * nn * ty * e * et * ef

  NUMBER = -1,
  TRANSFORM_OPT = -2, // for nonoption type -> option type value transform
}

export type Expr = Expr.NumberExpr | Expr.BinaryMath | Expr.Comparison | Expr.LogicCircuit |
                   Expr.TypeConversion | Expr.Unary | Expr.ListCons | Expr.Append | Expr.Get |
                   Expr.Set | Expr.Len | Expr.Chrs | Expr.Tuple | Expr.IfExpr | Expr.FunCall |
                   Expr.GetVar | Expr.Let | Expr.OptTransform | Expr.IfLet;

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

  export type UnaryToken = Token.NEG | Token.NOT;
  export class Unary implements ExprLike {
    constructor(public kind: UnaryToken, public type: CCType, public expr: Expr) {}
  }

  export class ListCons implements ExprLike {
    kind: Token.LIST = Token.LIST
    constructor(public type: ListType, public elements: Expr[]){}
  }

  export class Append implements ExprLike {
    constructor(public kind: Token.APP | Token.SAPP, public type: CCType, public left: Expr, public right: Expr) {}
  }

  export type GetToken = Token.GET | Token.SGET | Token.TGET;

  export class Get implements ExprLike {
    constructor(public kind: GetToken , public type: CCType, public list: Expr, public index: Expr) {}
  }

  export type SetToken = Token.SET | Token.SSET| Token.TSET;

  export class Set implements ExprLike {
    constructor(public kind: SetToken, public type: CCType, public list: Expr, public index: Expr, public value: Expr) {}
  }

  export class Len implements ExprLike {
    kind: Token.LEN = Token.LEN
    type: CCType = BaseType.Int
    constructor(public value: Expr){}
  }

  export class Chrs implements ExprLike {
    kind: Token.CHRS = Token.CHRS
    type: CCType = BaseType.String
    constructor(public value: Expr){}
  }

  export class Tuple implements ExprLike {
    kind: Token.TUP = Token.TUP
    constructor(public type: TupleType, public values: Expr[]){}
  }

  export class IfExpr implements ExprLike {
    kind: Token.IF = Token.IF
    constructor(public type: CCType, public cond: Expr, public trueVal: Expr, public falseVal: Expr){}
  }

  export class FunCall implements ExprLike {
    kind: Token.FUNCALL = Token.FUNCALL
    constructor(public type: CCType, public func: FunctionObj, public args: Expr[]){}
  }

  export class GetVar implements ExprLike {
    kind: Token.GETVAR = Token.GETVAR
    constructor(public type: CCType, public id: number){};
  }

  export class Let implements ExprLike {
    kind: Token.LET = Token.LET
    constructor(public type: CCType, public id: number, public value: Expr, public inExpr: Expr){}
  }

  export class OptTransform implements ExprLike {
    kind: Token.TRANSFORM_OPT = Token.TRANSFORM_OPT
    constructor(public type: OptionType, public originalType: NonOptionType, public value: Expr){}
  }

  export class IfLet implements ExprLike {
    kind: Token.IFL = Token.IFL
    constructor(public type: CCType, public id: number, public convertType: CCType, public value: Expr, public trueVal: Expr, public falseVal: Expr) {}
  }
}
