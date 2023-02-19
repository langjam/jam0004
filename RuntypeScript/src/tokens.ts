export const SIMPLE = Symbol("simple");
export const IDENTIFIER = Symbol("identifier");
export const NUMBER = Symbol("number");
export const STRING = Symbol("string");

export const SIMPLE_TOKENS = [
	"-=",
	"!=",
	"*=",
	"/=",
	"&=",
	"%=",
	"+=",
	"<=",
	"==",
	">=",
	"|=",
	"-",
	",",
	";",
	":",
	"(",
	")",
	"[",
	"]",
	"{",
	"}",
	"*",
	"/",
	"&",
	"#",
	"%",
	"+",
	"<",
	"=",
	">",
	"|",
	"~",
] as const;

export const KEYWORD_LIKE_TOKENS = [
	"and",
	"break",
	"const",
	"continue",
	"decltype",
	"elif",
	"else",
	"extends",
	"fn",
	"if",
	"not",
	"or",
	"return",
	"sig",
	"var",
	"while",
] as const;

export type SimpleToken = {
	readonly type: typeof SIMPLE;
	readonly token: typeof SIMPLE_TOKENS[number] | typeof KEYWORD_LIKE_TOKENS[number]
};

export type IdentifierToken = {
	readonly type: typeof IDENTIFIER;
	readonly name: string;
};

export type NumberToken = {
	readonly type: typeof NUMBER;
	readonly value: number;
};

export type StringToken = {
	readonly type: typeof STRING;
	readonly value: string;
};

export type Token =
	| SimpleToken
	| IdentifierToken
	| NumberToken
	| StringToken;

export const SimpleToken = (token: SimpleToken["token"]): SimpleToken => ({ type: SIMPLE, token });
export const IdentifierToken = (name: string): IdentifierToken => ({ type: IDENTIFIER, name });
export const NumberToken = (value: number): NumberToken => ({ type: NUMBER, value });
export const StringToken = (value: string): StringToken => ({ type: STRING, value });
