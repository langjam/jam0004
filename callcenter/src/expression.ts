export enum TypeKind {
  Int = 4,
  Float = 3,
  Bool = 2,
  String = 7,
  List = 5,
  Tuple = 8,
  Option = 6,
  Function = 9,
  None = 0,
}

export enum BaseType {
  Int = TypeKind.Int,
  Float = TypeKind.Float,
  Bool = TypeKind.Bool,
  String = TypeKind.String,
  None = TypeKind.None
}

export type CCType = BaseType | ListType | TupleType | OptionType | FunctionType

interface TypeLike {
  kind: TypeKind;
  typelabel: string;
}

export class ListType implements TypeLike {
  kind: TypeKind.List;
  typelabel: string

  constructor(public elementType: CCType) {
    this.kind = TypeKind.List;
    this.typelabel = this.kind.toString() + typelabel(elementType);
  }
}

export class TupleType implements TypeLike {
  kind: TypeKind
  typelabel: string

  constructor(public productTypes: CCType[]) {
    this.kind = TypeKind.Tuple;
    this.typelabel = this.kind.toString() + padZero(productTypes.length.toString(), 2) + productTypes.map(typelabel);
  }
}

export class OptionType implements TypeLike {
  kind: TypeKind
  typelabel: string

  constructor(public sumTypes: CCType[]) {
    this.kind = TypeKind.Option;
    this.typelabel = this.kind.toString() + padZero(sumTypes.length.toString(), 2) + sumTypes.map(typelabel);
  }
}

export class FunctionType implements TypeLike {
  kind: TypeKind
  typelabel: string

  constructor(public returnType: CCType, public paramTypes: CCType[]) {
    this.kind = TypeKind.Function;
    this.typelabel = this.kind.toString() + padZero(paramTypes.length.toString(), 2) + paramTypes.map(typelabel) + typelabel(returnType);
  }
}

export function isTypeEqual (a: CCType, b: CCType) : boolean {
  if (isBaseType(a)) {
    if (isBaseType(b)) return a === b;
    return false;
  } else if (isBaseType(b)){
    return false;
  }

  return a.typelabel === b.typelabel;
}

export function isBaseType(t: CCType) : t is BaseType {
  return !isNaN(t as any);
}

export function isListType(t: CCType) : t is ListType {
  return (t as TypeLike).kind === TypeKind.List;
}

export function isTupleType(t: CCType) : t is TupleType {
  return (t as TypeLike).kind === TypeKind.Tuple;
}

export function isOptionType(t: CCType) : t is OptionType {
  return (t as TypeLike).kind === TypeKind.Option;
}

export function isFunctionType(t: CCType) : t is FunctionType {
  return (t as TypeLike).kind === TypeKind.Function;
}

function typelabel(t: CCType) : string {
  if (isBaseType(t)) return t.toString();
  return t.typelabel;
}

function padZero(s: string, targetLength: number) {
  return padStart(s, targetLength, "0");
}

function padStart(s: string, targetLength: number, pad: string) {
  return pad.repeat(targetLength - s.length) + s;
}

export type JSValue = number | boolean | string | Function | JSValue[];

export class Value {
  constructor(public type: CCType, value: JSValue){}
}

interface ExprLike {
  type: CCType
  value(): Value
}

export enum StdFunction {
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

  NOT = 668, // bool -> bool

  // LIST
  // a [a] -> [a] | [a] a -> [a] | [a] -> [a] -> [a]
  // int string -> string | string int -> string | string string -> string

  APP = 277, // app a [a] / [a] a / [a] [a]

  LIST = 5478, // *LIST nn * a * a * a * ...

  // string | [a], int -> string | a
  GET = 438, // get list index

  // string | [a], int, int | string | a -> string | [a]
  SET = 738, // set list index value

  // string | [a] -> int
  LEN = 536, // len list

  // string | [a], int -> string | [a]
  REM = 736, // rem list index

  // any -> string
  STR = 787, // str any

  CHRS = 2488, // [int] -> str

  // tuple
  TUP = 887, // TUP nn e e ...
  TGET = 8438, // 8438nn tuple int
  TSET = 8738, // 8738nn tuple int e

  IF = 43, // if * c * t * f
  IFL = 435, // ifl nn * ty * e * et * ef

  GETVAR = 0, // *0nn,
  FUNCALL = 1, // *1nnn direct call
  LET = 538, // *LET nn * v * e
  CALL = 2255, // *call nn * e * param...

  NUMBER = -1
}
