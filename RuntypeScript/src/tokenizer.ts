import { IdentifierToken, KEYWORD_LIKE_TOKENS, NumberToken, SIMPLE_TOKENS, SimpleToken, StringToken, Token } from "./tokens.js";

type Context = {
	ptr: number;
	code: string;
	tokens: Token[];
};

export function tokenize(code: string): Token[] {
	const ctx: Context = {
		ptr: 0,
		code,
		tokens: [],
	}

	while (ctx.ptr < ctx.code.length) {
		if (skipWhitespace(ctx)) continue;
		if (skipComment(ctx)) continue;
		if (tokenizeNumber(ctx)) continue;
		if (tokenizeString(ctx)) continue;
		if (tokenizeKeyword(ctx)) continue;
		if (tokenizeSimple(ctx)) continue;
		throw new Error("Unrecognized token at position " + ctx.ptr);
	}

	return ctx.tokens;
}

function skipWhitespace(ctx: Context): boolean {
	let skipped = false;
	while (
		ctx.ptr < ctx.code.length
		&& [" ", "\n", "\t", "\r"].indexOf(ctx.code.charAt(ctx.ptr)) !== -1
	) {
		skipped = true;
		ctx.ptr += 1;
	}
	return skipped;
}

function skipComment(ctx: Context): boolean {
	if (!ctx.code.startsWith("//", ctx.ptr)) {
		return false;
	}

	const end = ctx.code.indexOf("\n", ctx.ptr + 2);
	ctx.ptr = end !== -1 ? end : ctx.code.length;
	return true;
}

function tokenizeNumber(ctx: Context): boolean {
	const start = ctx.ptr;
	let end = start;
	let dot = false;

	while (
		end < ctx.code.length
		&& (
			ctx.code.charCodeAt(end) >= "0".charCodeAt(0) && ctx.code.charCodeAt(end) <= "9".charCodeAt(0)
			|| dot === false && ctx.code.charAt(end) == "."
		)
	) {
		if (ctx.code.charAt(end) === ".") dot = true;
		end += 1;
	}

	if (start < end) {
		ctx.ptr = end;
		const value = Number.parseFloat(ctx.code.substring(start, end));
		ctx.tokens.push(NumberToken(value));
		return true;
	}
	return false;
}

function tokenizeString(ctx: Context): boolean {
	if (ctx.code.charAt(ctx.ptr) !== "\"") {
		return false;
	}

	let str: string = "";
	while (true) {
		ctx.ptr += 1;
		if (ctx.ptr >= ctx.code.length) throw new Error("EOF inside string literal");

		let char = ctx.code.charAt(ctx.ptr);
		if (char === "\"") {
			ctx.tokens.push(StringToken(str));
			ctx.ptr += 1;
			return true;
		}

		if (char === "\\") {
			ctx.ptr += 1;
			if (ctx.ptr >= ctx.code.length) throw new Error("EOF inside string literal");

			char = ctx.code.charAt(ctx.ptr);
			switch (char) {
				case "\\": char = "\\"; break;
				case "\"": char = "\""; break;
				case "n": char = "\n"; break;
				case "t": char = "\t"; break;
				case "r": char = "\r"; break;
				default: throw new Error(`Invalid escape sequence \\${char}`);
			}
		}

		str += char;
	}
}

function tokenizeKeyword(ctx: Context): boolean {
	if (!isIdentifierStart(ctx.code.charAt(ctx.ptr))) {
		return false;
	}

	const start = ctx.ptr;
	let end = start + 1;
	while (
		end < ctx.code.length
		&& isIdentifierMiddle(ctx.code.charAt(end))
	) {
		end += 1;
	}

	ctx.ptr = end;
	const identifier = ctx.code.substring(start, end);
	if (isKeyword(identifier)) {
		ctx.tokens.push(SimpleToken(identifier));
	} else {
		ctx.tokens.push(IdentifierToken(identifier));
	}
	return true;
}

function tokenizeSimple(ctx: Context): boolean {
	for (const token of SIMPLE_TOKENS) {
		if (ctx.code.startsWith(token, ctx.ptr)) {
			ctx.tokens.push(SimpleToken(token));
			ctx.ptr += token.length;
			return true;
		}
	}
	return false;
}

function isIdentifierStart(char: string) {
	return /^\p{L}|_$/u.test(char);
}

function isIdentifierMiddle(char: string) {
	return /^\p{L}|\p{Nd}|\p{Nl}|_$/u.test(char);
}

function isKeyword(identifier: string): identifier is typeof KEYWORD_LIKE_TOKENS[number] {
	return KEYWORD_LIKE_TOKENS.includes(identifier as typeof KEYWORD_LIKE_TOKENS[number]);
}
