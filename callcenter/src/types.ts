export enum TypeKind {
  Int = 4,
  Float = 3,
  Bool = 2,
  String = 7,
  List = 5,
  Tuple = 8,
  Option = 6,
  Function = 9,
  Custom = 1,
  None = 0,
}

export enum BaseType {
  Int = TypeKind.Int,
  Float = TypeKind.Float,
  Bool = TypeKind.Bool,
  String = TypeKind.String,
  None = TypeKind.None
}

export type NonOptionType = BaseType | ListType | TupleType | FunctionType
export type CCType =  NonOptionType | OptionType

interface TypeLike {
  kind: TypeKind
  typelabel: string
  typename: string
}

export class ListType implements TypeLike {
  kind: TypeKind.List;
  typelabel: string;
  typename: string;

  constructor(public elementType: CCType) {
    this.kind = TypeKind.List;
    this.typelabel = this.kind.toString() + typelabel(elementType);
    this.typename = typename(elementType) + "[]";
  }
}

export class TupleType implements TypeLike {
  kind: TypeKind.Tuple
  typelabel: string
  typename: string

  constructor(public productTypes: CCType[]) {
    this.kind = TypeKind.Tuple;
    this.typelabel = this.kind.toString() + padZero(productTypes.length.toString(), 2) + productTypes.map(typelabel);
    this.typename = `(${productTypes.map(typename).join(", ")})`;
  }
}

export class OptionType implements TypeLike {
  kind: TypeKind.Option
  typelabel: string
  typename: string
  sumTypes: NonOptionType[]

  constructor(sumTypes: CCType[]) {
    this.kind = TypeKind.Option;
    this.sumTypes = [];

    // flatten OptionType
    for (let type of sumTypes) {
      if (isOptionType(type)) {
        for (let otherType of type.sumTypes) {
          if (!typeExists(otherType, this.sumTypes)) {
            this.sumTypes.push(otherType);
          }
        }
      } else if (!typeExists(type, this.sumTypes)) {
        this.sumTypes.push(type);
      }
    }

    this.typelabel = this.kind.toString() + padZero(sumTypes.length.toString(), 2) + sumTypes.map(typelabel);
    this.typename = sumTypes.map(typename).join(" | ");
  }
}

function typeExists(type: CCType, types: CCType[]) : boolean {
  for (let t of types) {
    if (isTypeEqual(t, type)) return true;
  }

  return false;
}

export class FunctionType implements TypeLike {
  kind: TypeKind.Function
  typelabel: string
  typename: string

  constructor(public returnType: CCType, public paramTypes: CCType[]) {
    this.kind = TypeKind.Function;
    this.typelabel = this.kind.toString() + padZero(paramTypes.length.toString(), 2) + paramTypes.map(typelabel) + typelabel(returnType);
    this.typename = `Func (${paramTypes.map(typename).join(", ")}) -> ${typename(returnType)}`;
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

export function coversType(a: CCType, b: CCType): boolean {
  // a coversType b if b is assignable to a

  if (isTypeEqual(a,b)) return true;

  if (!isOptionType(a)) return false;

  if (!isOptionType(b)) {
    // check if b is covered by any options in a
    for (let t of a.sumTypes) {
      if (coversType(t, b))
        return true;
    }
    return false;
  }

  // check for each options in b, it's covered by options in a
  for (let bt of b.sumTypes) {
    let covered = false;
    for (let at of a.sumTypes) {
      if (coversType(at, bt)) {
        covered = true;
        break;
      }
    }

    if (!covered) return false;
  }

  return true;
}

function typelabel(t: CCType) : string {
  if (isBaseType(t)) return t.toString();
  return t.typelabel;
}

export function typename(t: CCType): string {
  if (!isBaseType(t)) {
    return t.typename;
  }

  switch (t) {
    case BaseType.Bool: return "bool";
    case BaseType.Int: return "int";
    case BaseType.Float: return "float";
    case BaseType.String: return "string";
    default:
      return "none";
  }
}

function padZero(s: string, targetLength: number) {
  return padStart(s, targetLength, "0");
}

function padStart(s: string, targetLength: number, pad: string) {
  return pad.repeat(targetLength - s.length) + s;
}
