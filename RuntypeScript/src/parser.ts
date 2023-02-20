import * as tokens from "./tokens.js";
import * as expressions from "./expressions.js";
import * as statements from "./statements.js";
import * as values from "./values.js";

type Context = {
	ptr: number;
	tokens: tokens.Token[];
};

export function parse(tokens: tokens.Token[]): statements.Statement[] {
	const ctx: Context = {
		ptr: 0,
		tokens,
	};

	const statements: statements.Statement[] = [];
	while (ctx.ptr < ctx.tokens.length) {
		statements.push(parseStatement(ctx));
	}

	return statements;
}

// --- STATEMENTS --------------------------------------------------------------

function parseBlock(ctx: Context): statements.Statement[] {
	if (!eatSimpleToken(ctx, "{")) {
		throw new Error("\"{\" expected");
	}

	const ret: statements.Statement[] = [];
	while (!eatSimpleToken(ctx, "}")) {
		ret.push(parseStatement(ctx));
	}

	return ret;
}

function parseStatement(ctx: Context): statements.Statement {
	let stmt: statements.Statement | undefined;

	if (stmt = parseDeclaration(ctx)) return stmt;
	if (stmt = parseAssignment(ctx)) return stmt;
	if (stmt = parseIfElseChain(ctx)) return stmt;
	if (stmt = parseWhileLoop(ctx)) return stmt;
	if (stmt = parseReturn(ctx)) return stmt;
	if (stmt = parseBreak(ctx)) return stmt;
	if (stmt = parseContinue(ctx)) return stmt;
	if (stmt = parseExpressionStatement(ctx)) return stmt;

	throw new Error("Statement expected");
}

function parseDeclaration(ctx: Context): statements.Statement | undefined {
	let constant: boolean;
	if (eatSimpleToken(ctx, "var")) {
		constant = false;
	} else if (eatSimpleToken(ctx, "const")) {
		constant = true;
	} else {
		return undefined;
	}

	if (ctx.ptr >= ctx.tokens.length) {
		throw new Error("EOF while parsing declaration name");
	}
	const identifierToken = ctx.tokens[ctx.ptr];
	if (identifierToken.type !== tokens.IDENTIFIER) {
		throw new Error("Identifier expected for declaration name");
	}
	ctx.ptr += 1;

	let declaredType: expressions.Expression | undefined = undefined;
	if (eatSimpleToken(ctx, ":")) {
		declaredType = parseExpression(ctx);
		if (declaredType === undefined) {
			throw new Error("Expression expected to specify declared type");
		}
	}

	if (!eatSimpleToken(ctx, "=")) {
		throw new Error("\"=\" expected");
	}

	const value = parseExpression(ctx);
	if (value === undefined) {
		throw new Error("Expression expected to initialize declaration");
	}

	if (!eatSimpleToken(ctx, ";")) {
		throw new Error("\";\" expected");
	}

	return statements.DeclarationStatement(constant, identifierToken.name, declaredType, value);
}

function parseAssignment(ctx: Context): statements.Statement | undefined {
	const start = ctx.ptr;
	const lhs = parseExpression(ctx);
	if (lhs === undefined) {
		return undefined;
	}

	let shorthand: expressions.BinaryExpression["type"] | undefined;
	if (eatSimpleToken(ctx, "=")) {
		shorthand = undefined;
	} else if (eatSimpleToken(ctx, "+=")) {
		shorthand = expressions.ADD;
	} else if (eatSimpleToken(ctx, "-=")) {
		shorthand = expressions.SUB;
	} else if (eatSimpleToken(ctx, "*=")) {
		shorthand = expressions.MUL;
	} else if (eatSimpleToken(ctx, "/=")) {
		shorthand = expressions.DIV;
	} else if (eatSimpleToken(ctx, "%=")) {
		shorthand = expressions.MOD;
	} else if (eatSimpleToken(ctx, "|=")) {
		shorthand = expressions.UNION;
	} else if (eatSimpleToken(ctx, "&=")) {
		shorthand = expressions.INTERSECT;
	} else {
		ctx.ptr = start;
		return undefined;
	}

	let rhs = parseExpression(ctx);
	if (rhs === undefined) {
		throw new Error("Expression expected for assignment rhs");
	}

	if (!eatSimpleToken(ctx, ";")) {
		throw new Error("\";\" expected");
	}

	if (shorthand !== undefined) {
		rhs = expressions.BinaryExpression(shorthand, lhs, rhs);
	}

	return statements.AssignmentStatement(lhs, rhs);
}

function parseIfElseChain(ctx: Context): statements.Statement | undefined {
	if (!eatSimpleToken(ctx, "if")) {
		return undefined;
	}

	// NOTE We do a little trickery to remove `readonly` modifier.
	const chain: statements.IfElseChainStatement["chain"][number][] = [];
	while (true) {
		if (!eatSimpleToken(ctx, "(")) {
			throw new Error("\"(\" expected");
		}
		const condition = parseExpression(ctx);
		if (condition === undefined) {
			throw new Error("Expression expected for condition");
		}
		if (!eatSimpleToken(ctx, ")")) {
			throw new Error("\")\" expected");
		}
		const block = parseBlock(ctx);

		chain.push({ condition, block });

		if (!eatSimpleToken(ctx, "elif")) {
			break;
		}
	}

	let elseBlock: statements.Statement[] | undefined = undefined;
	if (eatSimpleToken(ctx, "else")) {
		elseBlock = parseBlock(ctx);
	}

	return statements.IfElseChainStatement(chain, elseBlock);
}

function parseWhileLoop(ctx: Context): statements.Statement | undefined {
	if (!eatSimpleToken(ctx, "while")) {
		return undefined;
	}

	if (!eatSimpleToken(ctx, "(")) {
		throw new Error("\"(\" expected");
	}
	const condition = parseExpression(ctx);
	if (condition === undefined) {
		throw new Error("Expression expected for condition");
	}
	if (!eatSimpleToken(ctx, ")")) {
		throw new Error("\")\" expected");
	}
	const block = parseBlock(ctx);

	return statements.WhileLoopStatement(condition, block);
}

function parseReturn(ctx: Context): statements.Statement | undefined {
	if (!eatSimpleToken(ctx, "return")) {
		return undefined;
	}

	if (eatSimpleToken(ctx, ";")) {
		return statements.ReturnStatement(undefined);
	}

	const expression = parseExpression(ctx);
	if (expression === undefined) {
		throw new Error("Expression or \";\" expected for return statement");
	}

	if (!eatSimpleToken(ctx, ";")) {
		throw new Error("\";\" expected");
	}

	return statements.ReturnStatement(expression);
}

function parseBreak(ctx: Context): statements.Statement | undefined {
	if (!eatSimpleToken(ctx, "break")) {
		return undefined;
	}

	if (!eatSimpleToken(ctx, ";")) {
		throw new Error("\";\" expected");
	}

	return statements.BreakStatement;
}

function parseContinue(ctx: Context): statements.Statement | undefined {
	if (!eatSimpleToken(ctx, "continue")) {
		return undefined;
	}

	if (!eatSimpleToken(ctx, ";")) {
		throw new Error("\";\" expected");
	}

	return statements.BreakStatement;
}

function parseExpressionStatement(ctx: Context): statements.Statement | undefined {
	const expression = parseExpression(ctx);
	if (expression === undefined) {
		return undefined;
	}

	if (!eatSimpleToken(ctx, ";")) {
		throw new Error("\";\" expected");
	}

	return statements.ExpressionStatement(expression);
}

// --- EXPRESSIONS -------------------------------------------------------------

function parseExpression(ctx: Context, parentPriority = -1): expressions.Expression | undefined {

	let ret = parseOperand(ctx);
	if (ret === undefined) return undefined;

	while (true) {

		// function call

		if (eatSimpleToken(ctx, "(")) {
			const args: expressions.Expression[] = [];
			while (true) {
				if (eatSimpleToken(ctx, ")")) break;

				const arg = parseExpression(ctx);
				if (arg === undefined) {
					throw new Error("Expression expected for function argument");
				}

				args.push(arg);
				if (eatSimpleToken(ctx, ")")) {
					break;
				}
				if (!eatSimpleToken(ctx, ",")) {
					throw new Error("\",\" expected");
				}
			}
			ret = expressions.CallExpression(ret, args);
		}

		else if (eatSimpleToken(ctx, "[")) {

			// typed array

			if (eatSimpleToken(ctx, "]")) {
				ret = expressions.TypedArrayExpression(ret);
			}

			// indexing

			else {
				const index = parseExpression(ctx);
				if (index === undefined) {
					throw new Error("Expression expected for index");
				}
				if (!eatSimpleToken(ctx, "]")) {
					throw new Error("\"]\" expected");
				}
				ret = expressions.BinaryExpression(expressions.INDEXING, ret, index);
			}
		}

		else break;
	}

	while (true) {
		if (ctx.ptr >= ctx.tokens.length) break;
		const op = isBinaryOp(ctx.tokens[ctx.ptr]);
		if (op === undefined  || parentPriority > op.priority) break;

		ctx.ptr += 1;

		const rhs = parseExpression(ctx, op.priority + 1);
		if (rhs === undefined) {
			throw new Error("Expression expected for rhs of a binary operation");
		}

		ret = expressions.BinaryExpression(op.expressionType, ret, rhs);
	}

	return ret;
}

function parseOperand(ctx: Context): expressions.Expression | undefined {

	if (ctx.ptr >= ctx.tokens.length) return undefined;
	const token = ctx.tokens[ctx.ptr];

	// unary

	const unaryOp = isUnaryOp(token);
	if (unaryOp !== undefined) {
		ctx.ptr += 1;

		const operand = parseExpression(ctx, unaryOp.priority);
		if (operand === undefined) {
			throw new Error("Expression expected for operand of a unary operation");
		}

		return expressions.UnaryExpression(unaryOp.expressionType, operand);
	}

	// group

	if (eatSimpleToken(ctx, "(")) {
		const subExpression = parseExpression(ctx);
		if (subExpression === undefined) {
			throw new Error("Expression excepted within parenthesis");
		}
		if (!eatSimpleToken(ctx, ")")) {
			throw new Error("\")\" expected to close expression within parenthesis");
		}

		return subExpression;
	}

	// decltype

	if (eatSimpleToken(ctx, "decltype")) {
		if (ctx.ptr >= ctx.tokens.length) {
			throw new Error("EOF while parsing decltype operand");
		}

		const nextToken = ctx.tokens[ctx.ptr];
		if (nextToken.type !== tokens.IDENTIFIER) {
			throw new Error("decltype expression supports pure identifiers only");
		}

		ctx.ptr += 1;
		return expressions.DecltypeExpression(nextToken.name);
	}

	// literals

	const literal = parseLiteral(ctx);
	if (literal !== undefined) {
		return literal;
	}

	// identifier

	if (token.type === tokens.IDENTIFIER) {
		ctx.ptr += 1;
		return expressions.IdentifierExpression(token.name);
	}

	return undefined;
}

function parseLiteral(ctx: Context): expressions.Expression | undefined {

	if (ctx.ptr >= ctx.tokens.length) return undefined;
	const token = ctx.tokens[ctx.ptr];

	// number

	if (token.type === tokens.NUMBER) {
		ctx.ptr += 1;
		return expressions.LiteralExpression(values.NumberLiteralValue(token.value));
	}

	// string

	if (token.type === tokens.STRING) {
		ctx.ptr += 1;
		return expressions.LiteralExpression(values.StringLiteralValue(token.value));
	}

	// tuple

	if (eatSimpleToken(ctx, "[")) {
		const value: expressions.Expression[] = [];
		while (true) {
			if (eatSimpleToken(ctx, "]")) {
				return expressions.TupleExpression(value);
			}

			const element = parseExpression(ctx);
			if (element === undefined) {
				throw new Error("Expression expected for tuple element");
			}

			value.push(element);
			if (eatSimpleToken(ctx, "]")) {
				return expressions.TupleExpression(value);
			}
			if (!eatSimpleToken(ctx, ",")) {
				throw new Error("\",\" expected");
			}
		}
	}

	// object

	if (eatSimpleToken(ctx, "{")) {
		const value: { [_: string]: expressions.Expression } = {};
		while (true) {
			if (eatSimpleToken(ctx, "}")) {
				return expressions.ObjectExpression(value);
			}

			if (ctx.ptr >= ctx.tokens.length) {
				throw new Error("EOF while parsing object property name");
			}

			const identifierToken = ctx.tokens[ctx.ptr];
			if (identifierToken.type !== tokens.IDENTIFIER) {
				throw new Error("Identifier expected for object property name");
			}
			if (identifierToken.name in value) {
				throw new Error(`Duplicate property name in object literal: ${identifierToken.name}`);
			}
			ctx.ptr += 1;

			if (!eatSimpleToken(ctx, ":")) {
				throw new Error("\":\" expected");
			}

			const propValue = parseExpression(ctx);
			if (propValue === undefined) {
				throw new Error("Expression expected for object property value");
			}

			value[identifierToken.name] = propValue;
			if (eatSimpleToken(ctx, "}")) {
				return expressions.ObjectExpression(value);
			}
			if (!eatSimpleToken(ctx, ",")) {
				throw new Error("\",\" expected");
			}
		}
	}

	// signature

	if (eatSimpleToken(ctx, "sig")) {
		if (!eatSimpleToken(ctx, "(")) {
			throw new Error("\"(\" expected");
		}

		const argumentTypes: expressions.Expression[] = [];
		while (true) {
			if (eatSimpleToken(ctx, ")")) break;

			const argType = parseExpression(ctx);
			if (argType === undefined) {
				throw new Error("Expression expected for signature argument type");
			}

			argumentTypes.push(argType);
			if (eatSimpleToken(ctx, ")")) {
				break;
			}
			if (!eatSimpleToken(ctx, ",")) {
				throw new Error("\",\" expected");
			}
		}
		const returnType = parseExpression(ctx);
		if (returnType === undefined) {
			throw new Error("Expression expected for signature return type");
		}

		return expressions.SignatureExpression(argumentTypes, returnType);
	}

	// function

	if (eatSimpleToken(ctx, "fn")) {
		if (!eatSimpleToken(ctx, "(")) {
			throw new Error("\"(\" expected");
		}

		const args: expressions.FunctionArgument[] = [];
		while (true) {
			if (eatSimpleToken(ctx, ")")) break;

			if (ctx.ptr >= ctx.tokens.length) {
				throw new Error("EOF while parsing function argument name");
			}

			const identifierToken = ctx.tokens[ctx.ptr];
			if (identifierToken.type !== tokens.IDENTIFIER) {
				throw new Error("Identifier expected for function argument name");
			}
			if (args.some(arg => arg.name === identifierToken.name)) {
				throw new Error(`Duplicate argument name in function literal: ${identifierToken.name}`);
			}
			ctx.ptr += 1;

			if (!eatSimpleToken(ctx, ":")) {
				throw new Error("\":\" expected");
			}

			const argType = parseExpression(ctx);
			if (argType === undefined) {
				throw new Error("Expression expected for signature argument type");
			}

			args.push({ name: identifierToken.name, type: argType });
			if (eatSimpleToken(ctx, ")")) {
				break;
			}
			if (!eatSimpleToken(ctx, ",")) {
				throw new Error("\",\" expected");
			}
		}
		const returnType = parseExpression(ctx);
		if (returnType === undefined) {
			throw new Error("Expression expected for signature return type");
		}

		const block = parseBlock(ctx);

		return expressions.FunctionExpression(args, returnType, block);
	}

	return undefined;
}

/* OPERATOR PRIORITY
 * -1 (implicit)
 *  0 or
 *  1 and
 *  2 <, >, <=, >=, ==, !=, extends
 *  3 |
 *  4 &
 *  5 +, - (binary)
 *  6 *, /, &
 *  7 not, - (unary), #, ~, decltype
 */

type UnaryOp = {
	expressionType: expressions.UnaryExpression["type"];
	priority: number;
};

function isUnaryOp(token: tokens.Token): UnaryOp | undefined {
	if (token.type !== tokens.SIMPLE) {
		return undefined;
	}

	switch (token.token) {
		case "not": return { expressionType: expressions.NOT, priority: 7 };
		case "-": return { expressionType: expressions.NEGATE, priority: 7 };
		case "#": return { expressionType: expressions.ARRAY_LENGTH, priority: 7 };
		case "~": return { expressionType: expressions.DELITERALIZE, priority: 7 };
		default: return undefined;
	}
}

type BinaryOp = {
	expressionType: expressions.BinaryExpression["type"];
	priority: number;
}

function isBinaryOp(token: tokens.Token): BinaryOp | undefined {
	if (token.type !== tokens.SIMPLE) {
		return undefined;
	}

	switch (token.token) {
		case "+": return { expressionType: expressions.ADD, priority: 5 };
		case "-": return { expressionType: expressions.SUB, priority: 5 };
		case "*": return { expressionType: expressions.MUL, priority: 6 };
		case "/": return { expressionType: expressions.DIV, priority: 6 };
		case "%": return { expressionType: expressions.MOD, priority: 6 };
		case "==": return { expressionType: expressions.EQUAL, priority: 2 };
		case "!=": return { expressionType: expressions.NOT_EQUAL, priority: 2 };
		case ">": return { expressionType: expressions.GREATER, priority: 2 };
		case ">=": return { expressionType: expressions.GREATER_OR_EQUAL, priority: 2 };
		case "<": return { expressionType: expressions.LESS, priority: 2 };
		case "<=": return { expressionType: expressions.LESS_OR_EQUAL, priority: 2 };
		case "and": return { expressionType: expressions.AND, priority: 1 };
		case "or": return { expressionType: expressions.OR, priority: 0 };
		case "|": return { expressionType: expressions.UNION, priority: 3 };
		case "&": return { expressionType: expressions.INTERSECT, priority: 4 };
		case "extends": return { expressionType: expressions.EXTENDS, priority: 2 };
		default: return undefined;
	}
}

// -----------------------------------------------------------------------------

function eatSimpleToken(ctx: Context, token: tokens.SimpleToken["token"]): boolean {
	if (ctx.ptr >= ctx.tokens.length) return false;
	const currentToken = ctx.tokens[ctx.ptr];

	if (currentToken.type === tokens.SIMPLE && currentToken.token === token) {
		ctx.ptr += 1;
		return true;
	} else {
		return false;
	}
}
