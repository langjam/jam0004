import type { Scope } from "./interpreter.js";
import type { Statement } from "./statements.js";

export const NIL = Symbol("nil");
export const FALSE = Symbol("false");
export const TRUE = Symbol("true");
export const BOOLEAN = Symbol("boolean");
export const STRING = Symbol("string");
export const STRING_LITERAL = Symbol("string literal");
export const NUMBER = Symbol("number");
export const NUMBER_LITERAL = Symbol("number literal");
export const TYPED_ARRAY = Symbol("typed array");
export const TUPLE = Symbol("tuple");
export const OBJECT = Symbol("object");
export const SIGNATURE = Symbol("signature");
export const FUNCTION = Symbol("function");
export const UNION = Symbol("union");
export const ANY = Symbol("any");

export type NilValue = {
	readonly type: typeof NIL;
};

export type FalseValue = {
	readonly type: typeof FALSE;
};

export type TrueValue = {
	readonly type: typeof TRUE;
};

export type BooleanValue = {
	readonly type: typeof BOOLEAN;
};

export type StringValue = {
	readonly type: typeof STRING;
};

export type StringLiteralValue = {
	readonly type: typeof STRING_LITERAL;
	readonly value: string;
};

export type NumberValue = {
	readonly type: typeof NUMBER;
};

export type NumberLiteralValue = {
	readonly type: typeof NUMBER_LITERAL;
	readonly value: number;
};

export type TypedArrayValue = {
	readonly type: typeof TYPED_ARRAY;
	readonly elementType: Value;
}

// NOTE Mutable
export type TupleValue = {
	readonly type: typeof TUPLE;
	readonly value: Value[];
};

// NOTE Mutable
export type ObjectValue = {
	readonly type: typeof OBJECT;
	readonly value: { [_: string]: Value };
};

export type SignatureValue = {
	readonly type: typeof SIGNATURE;
	readonly argumentTypes: readonly Value[];
	readonly returnType: Value;
};

export type FunctionValue = {
	readonly type: typeof FUNCTION;
	readonly arguments: readonly FunctionArgument[];
	readonly returnType: Value;
	readonly body: readonly Statement[] | IntrinsicFunction;
	readonly scopeStack: readonly Scope[];
};

export type UnionValue = {
	readonly type: typeof UNION;
	readonly values: readonly Exclude<Value, UnionValue>[];
};

export type AnyValue = {
	readonly type: typeof ANY;
};

export type Value =
	| NilValue
	| FalseValue
	| TrueValue
	| BooleanValue
	| StringValue
	| StringLiteralValue
	| NumberValue
	| NumberLiteralValue
	| TypedArrayValue
	| TupleValue
	| ObjectValue
	| SignatureValue
	| FunctionValue
	| UnionValue
	| AnyValue;

export const NilValue: NilValue = { type: NIL };
export const FalseValue: FalseValue = { type: FALSE };
export const TrueValue: TrueValue = { type: TRUE };
export const BooleanValue: BooleanValue = { type: BOOLEAN };
export const StringValue: StringValue = { type: STRING };
export const StringLiteralValue = (value: string): StringLiteralValue => ({ type: STRING_LITERAL, value });
export const NumberValue: NumberValue = { type: NUMBER };
export const NumberLiteralValue = (value: number): NumberLiteralValue => ({ type: NUMBER_LITERAL, value });
export const TypedArrayValue = (elementType: Value): TypedArrayValue => ({ type: TYPED_ARRAY, elementType });
export const TupleValue = (value: readonly Value[]): TupleValue => ({ type: TUPLE, value: [...value] });
export const ObjectValue = (value: { readonly [_: string]: Value }): ObjectValue => ({ type: OBJECT, value: { ...value } });
export const SignatureValue = (argumentTypes: readonly Value[], returnType: Value): SignatureValue => ({ type: SIGNATURE, argumentTypes, returnType });
export const FunctionValue = (args: readonly FunctionArgument[], returnType: Value, body: readonly Statement[], scopeStack: readonly Scope[]): FunctionValue => ({ type: FUNCTION, arguments: args, returnType, body, scopeStack: [...scopeStack] });
export const FunctionValueIntrinsic = (args: readonly FunctionArgument[], returnType: Value, body: IntrinsicFunction): FunctionValue => ({ type: FUNCTION, arguments: args, returnType, body, scopeStack: [] });
export const UnionValue = (values: readonly Exclude<Value, UnionValue>[]): UnionValue => ({ type: UNION, values });
export const AnyValue: AnyValue = { type: ANY };

export type FunctionArgument = {
	name: string;
	type: Value;
};

export type IntrinsicFunction = (...args: Value[]) => Value;

export function deliteralize(value: Value): Value {

	switch (value.type) {
		case NIL: return NilValue;
		case FALSE: return BooleanValue;
		case TRUE: return BooleanValue;
		case BOOLEAN: return BooleanValue;
		case STRING: return StringValue;
		case STRING_LITERAL: return StringValue;
		case NUMBER: return NumberValue;
		case NUMBER_LITERAL: return NumberValue;
		case TYPED_ARRAY: return value;
		case TUPLE: return TypedArrayValue(unionOf(...value.value.map(v => deliteralize(v))));
		case OBJECT: return ObjectValue(Object.fromEntries(Object.entries(value.value).map(([k, v]) => ([k, deliteralize(v)]))));
		case SIGNATURE: return value;
		case FUNCTION: return SignatureValue(value.arguments.map(a => a.type), value.returnType);
		case UNION: return unionOf(...value.values.map(v => deliteralize(v)));
		case ANY: return AnyValue;
	}
}

export function union(a: Value, b: Value): Value;
export function union(a: Value | undefined, b: Value | undefined): Value | undefined
export function union(a: Value | undefined, b: Value | undefined): Value | undefined {

	if (a === undefined || b === undefined) {
		if (a === undefined) {
			return b;
		} else {
			return a;
		}
	}

	if (a.type === ANY || b.type === ANY) {
		return AnyValue;
	}

	if (a.type === UNION || b.type === UNION) {
		if (a.type === UNION) {
			if (b.type === UNION) {
				return unionOf(...a.values, ...b.values);
			} else {
				const values: Exclude<Value, UnionValue>[] = a.values.map(x => union(x, b)).flatMap(x => x.type === UNION ? x.values : x);
				const unique = values.reduce((a: Exclude<Value, UnionValue>[], x) => a.every(y => !equals(x, y)) ? [...a, x] : a, []);
				if (unique.length === 1) {
					return unique[0];
				} else {
					return UnionValue(unique);
				}
			}
		} else {
			return unionOf(a, ...(b as UnionValue).values)
		}
	}

	switch (a.type) {
		case NIL: {
			switch (b.type) {
				case NIL:
					return NilValue;
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case FALSE: {
			switch (b.type) {
				case NIL:
					return UnionValue([a, b]);
				case FALSE:
					return FalseValue;
				case TRUE:
				case BOOLEAN:
					return BooleanValue;
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case TRUE: {
			switch (b.type) {
				case NIL:
					return UnionValue([a, b]);
				case FALSE:
					return BooleanValue;
				case TRUE:
					return TrueValue;
				case BOOLEAN:
					return BooleanValue;
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case BOOLEAN: {
			switch (b.type) {
				case NIL:
					return UnionValue([a, b]);
				case FALSE:
				case TRUE:
				case BOOLEAN:
					return BooleanValue;
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case STRING: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
					return UnionValue([a, b]);
				case STRING:
				case STRING_LITERAL:
					return StringValue;
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case STRING_LITERAL: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
					return UnionValue([a, b]);
				case STRING:
					return StringValue;
				case STRING_LITERAL:
					return a.value === b.value ? a : UnionValue([a, b]);
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case NUMBER: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
					return UnionValue([a, b]);
				case NUMBER:
				case NUMBER_LITERAL:
					return NumberValue;
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case NUMBER_LITERAL: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
					return UnionValue([a, b]);
				case NUMBER:
					return NumberValue;
				case NUMBER_LITERAL:
					return Object.is(a.value, b.value) ? a : UnionValue([a, b]);
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case TYPED_ARRAY: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
					return UnionValue([a, b]);
				case TYPED_ARRAY:
					return equals(a.elementType, b.elementType) ? a : UnionValue([a, b]);
				case TUPLE:
					return b.value.every(v => assignableTo(v, a.elementType)) ? a : UnionValue([a, b]);
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case TUPLE: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
					return UnionValue([a, b]);
				case TYPED_ARRAY:
					return a.value.every(v => assignableTo(v, b.elementType)) ? b : UnionValue([a, b]);
				case TUPLE:
					return assignableTo(a, b) ? a : assignableTo(b, a) ? b : UnionValue([a, b]);
				case OBJECT:
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case OBJECT: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
					return UnionValue([a, b]);
				case OBJECT: {
					return assignableTo(a, b) ? a : assignableTo(b, a) ? b : UnionValue([a, b]);
				}
				case SIGNATURE:
				case FUNCTION:
					return UnionValue([a, b]);
			}
		}
		case SIGNATURE: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
					return UnionValue([a, b]);
				case SIGNATURE:
					return assignableTo(a, b) ? a : assignableTo(b, a) ? b : UnionValue([a, b]);
				case FUNCTION:
					return assignableTo(b, a) ? a : UnionValue([a, b]);
			}
		}
		case FUNCTION: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case OBJECT:
				case SIGNATURE:
					return assignableTo(a, b) ? b : UnionValue([a, b]);
				case FUNCTION:
					return equals(a, b) ? a : UnionValue([a, b]);
			}
		}
	}
}

export function unionOf(...values: Value[]): Value;
export function unionOf(...values: (Value | undefined)[]): Value | undefined;
export function unionOf(...values: (Value | undefined)[]): Value | undefined {
	return values.reduce((a, x) => union(a, x));
}

export function intersection(a: Value | undefined, b: Value | undefined): Value | undefined {

	if (a === undefined || b === undefined) {
		return undefined;
	}

	if (a.type === ANY || b.type === ANY) {
		if (a.type === ANY) {
			return b;
		} else {
			return a;
		}
	}

	if (a.type === OBJECT || b.type === OBJECT) {
		if (a.type === OBJECT && b.type === OBJECT) {
			const aKeys = Object.keys(a.value);
			const entries: [string, Value][] = [];
			for (const k of aKeys) {
				const i = intersection(a.value[k], b.value[k]);
				if (i === undefined) return undefined;
				entries.push([k, i]);
			}
			return ObjectValue(Object.fromEntries(entries));
		} else {
			return undefined;
		}
	}

	if (a.type === UNION || b.type === UNION) {
		if (a.type === UNION) {
			/* (A1 | A2 | ... | AN) & B =
			 * = (A1 & B) | (A2 & B) | ... | (AN & B)
			 */
			return unionOf(...a.values.map(v => intersection(v, b)));
		} else {
			/* A & (B1 | B2 | ... | BN) =
			 * = (A & B1) | (A & B2) | ... | (A & BN)
			 */
			return unionOf(...(b as UnionValue).values.map(v => intersection(a, v)));
		}
	}

	switch (a.type) {
		case NIL: {
			switch (b.type) {
				case NIL:
					return NilValue;
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case FALSE: {
			switch (b.type) {
				case NIL:
					return undefined;
				case FALSE:
					return FalseValue;
				case TRUE:
					return undefined;
				case BOOLEAN:
					return FalseValue;
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case TRUE: {
			switch (b.type) {
				case NIL:
					return undefined;
				case FALSE:
					return undefined;
				case TRUE:
					return TrueValue;
				case BOOLEAN:
					return TrueValue;
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case BOOLEAN: {
			switch (b.type) {
				case NIL:
					return undefined;
				case FALSE:
					return FalseValue;
				case TRUE:
					return TrueValue;
				case BOOLEAN:
					return BooleanValue;
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case STRING: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
					return undefined;
				case STRING:
					return StringValue;
				case STRING_LITERAL:
					return b;
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case STRING_LITERAL: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
					return undefined;
				case STRING:
					return a;
				case STRING_LITERAL:
					return a.value === b.value ? a : undefined;
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case NUMBER: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
					return undefined;
				case NUMBER:
					return NumberValue;
				case NUMBER_LITERAL:
					return b;
				case TYPED_ARRAY:
				case TUPLE:
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case NUMBER_LITERAL: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
					return undefined;
				case NUMBER:
					return b;
				case NUMBER_LITERAL:
					return Object.is(a.value, b.value) ? a : undefined;
				case TYPED_ARRAY:
				case TUPLE:
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case TYPED_ARRAY: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
					return undefined;
				case TYPED_ARRAY: {
					const i = intersection(a.elementType, b.elementType);
					if (i === undefined) return undefined;
					return TypedArrayValue(i);
				}
				case TUPLE: {
					const value: Value[] = [];
					for (const v of b.value) {
						const i = intersection(a.elementType, v);
						if (i === undefined) return undefined;
						value.push(i);
					}
					return TupleValue(value);
				}
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case TUPLE: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
					return undefined;
				case TYPED_ARRAY: {
					const value: Value[] = [];
					for (const v of a.value) {
						const i = intersection(b.elementType, v);
						if (i === undefined) return undefined;
						value.push(i);
					}
					return TupleValue(value);
				}
				case TUPLE: {
					const length = Math.min(a.value.length, b.value.length);
					const value: Value[] = [];
					for (let ind = 0; ind < length; ++ind) {
						const av = a.value[ind];
						const bv = b.value[ind];
						const i = intersection(av, bv);
						if (i === undefined) return undefined;
						value.push(i);
					}
					return TupleValue(value);
				}
				case SIGNATURE:
				case FUNCTION:
					return undefined;
			}
		}
		case SIGNATURE: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
					return undefined;
				case SIGNATURE:
					return assignableTo(a, b) ? b : assignableTo(b, a) ? a : undefined;
				case FUNCTION:
					return assignableTo(b, a) ? b : undefined;
			}
		}
		case FUNCTION: {
			switch (b.type) {
				case NIL:
				case FALSE:
				case TRUE:
				case BOOLEAN:
				case STRING:
				case STRING_LITERAL:
				case NUMBER:
				case NUMBER_LITERAL:
				case TYPED_ARRAY:
				case TUPLE:
					return undefined;
				case SIGNATURE:
					return assignableTo(a, b) ? a : undefined;
				case FUNCTION:
					return equals(a, b) ? a : undefined;
			}
		}
	}
}

export function intersectionOf(...values: (Value | undefined)[]): Value | undefined {
	return values.reduce((a, x) => intersection(a, x));
}

export function assignableTo(value: Value, type: Value): boolean {

	if (value.type === UNION) {
		return value.values.every(v => assignableTo(v, type));
	}

	switch (type.type) {
		case NIL: return value.type === NIL;
		case FALSE: return value.type === FALSE;
		case TRUE: return value.type === TRUE;
		case BOOLEAN: return (
			value.type === FALSE
			|| value.type === TRUE
			|| value.type === BOOLEAN
		);
		case STRING: return (
			value.type === STRING
			|| value.type === STRING_LITERAL
		);
		case STRING_LITERAL: return value.type === STRING_LITERAL && value.value === type.value;
		case NUMBER: return (
			value.type === NUMBER
			|| value.type === NUMBER_LITERAL
		);
		case NUMBER_LITERAL: return value.type === NUMBER_LITERAL && Object.is(value.value, type.value);
		case TYPED_ARRAY: return (
			value.type === TYPED_ARRAY && assignableTo(value.elementType, type.elementType)
			|| value.type === TUPLE && (value.value.every(v => assignableTo(v, type.elementType)))
		);
		case TUPLE: return (
			value.type === TYPED_ARRAY && type.value.every(t => assignableTo(value.elementType, t))
			|| value.type === TUPLE && value.value.length >= type.value.length && type.value.every((t, i) => assignableTo(value.value[i], t))
		);
		case OBJECT: return value.type === OBJECT && Object.entries(type.value).every(([k, t]) => k in value.value && assignableTo(value.value[k], t));
		case SIGNATURE:
			return (
				(
					value.type === SIGNATURE
					&& value.argumentTypes.length <= type.argumentTypes.length
					&& value.argumentTypes.every((v, i) => assignableTo(type.argumentTypes[i], v))
					&& assignableTo(value.returnType, type.returnType)
				)
				|| value.type === FUNCTION && assignableTo(deliteralize(value), type)
			);
		case FUNCTION:
			return equals(value, type);
		case UNION:
			return type.values.some(t => assignableTo(value, t));
		case ANY:
			return true;
	}
}

export function equals(a: Value, b: Value): boolean {

	if (a.type === NIL && b.type === NIL) return true;
	if (a.type === FALSE && b.type === FALSE) return true;
	if (a.type === TRUE && b.type === TRUE) return true;
	if (a.type === BOOLEAN && b.type === BOOLEAN) return true;
	if (a.type === STRING && b.type === STRING) return true;
	if (a.type === STRING_LITERAL && b.type === STRING_LITERAL) return a.value === b.value;
	if (a.type === NUMBER && b.type === NUMBER) return true;
	if (a.type === NUMBER_LITERAL && b.type === NUMBER_LITERAL) return Object.is(a.value, b.value);
	if (a.type === TYPED_ARRAY && b.type === TYPED_ARRAY) return equals(a.elementType, b.elementType);
	if (a.type === TUPLE && b.type === TUPLE) return a.value.length === b.value.length && a.value.every((x, i) => equals(x, b.value[i]));
	if (a.type === OBJECT && b.type === OBJECT) {
		const aKeys = Object.keys(a);
		const bKeys = Object.keys(b);

		return (
			aKeys.length === bKeys.length
			&& aKeys.every(k => k in b.value && equals(a.value[k], b.value[k]))
		);
	}
	if (a.type === SIGNATURE && b.type === SIGNATURE) return a.argumentTypes.length === b.argumentTypes.length && a.argumentTypes.every((x, i) => equals(x, b.argumentTypes[i])) && equals(a.returnType, b.returnType);
	if (a.type === FUNCTION && b.type === FUNCTION) return a === b;
	if (a.type === UNION && b.type === UNION) return a.values.length === b.values.length && a.values.every(ax => b.values.some(bx => equals(ax, bx)));
	if (a.type === ANY && b.type === ANY) return true;

	return false;
}

export function toString(value: Value): string {
	switch (value.type) {
		case NIL: return "nil";
		case FALSE: return "false";
		case TRUE: return "true";
		case BOOLEAN: return "boolean";
		case STRING: return "string";
		case STRING_LITERAL: return JSON.stringify(value.value);
		case NUMBER: return "number";
		case NUMBER_LITERAL: return JSON.stringify(value.value);
		case TYPED_ARRAY: return value.elementType.type === UNION || value.elementType.type === SIGNATURE || value.elementType.type === FUNCTION
			? `(${toString(value.elementType)})[]`
			: `${toString(value.elementType)}[]`;
		case TUPLE: return value.value.length === 0 ? "[]" : "[" + value.value.map(v => toString(v)).join(", ") + "]";
		case OBJECT: return Object.keys(value.value).length === 0 ? "{}" : "{ " + Object.entries(value.value).map(([k, v]) => `${k}: ${toString(v)}`).join(", ") + " }";
		case SIGNATURE: return "sig (" + value.argumentTypes.map(t => toString(t)).join(", ") + ") " + toString(value.returnType);
		case FUNCTION: return "fn (" + value.arguments.map(a => `${a.name}: ${toString(a.type)}`).join(", ") + ") " + toString(value.returnType) + " {}";
		case UNION: return value.values.map(v => toString(v)).join(" | ");
		case ANY: return "any";
	}
}
