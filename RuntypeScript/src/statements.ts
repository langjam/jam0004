import type { Expression } from "./expressions.js";

export const DECLARATION = Symbol("declaration");
export const ASSIGNMENT = Symbol("assignment");
export const IF_ELSE_CHAIN = Symbol("if else chain");
export const WHILE_LOOP = Symbol("while loop");
export const EXPRESSION = Symbol("expression");
export const RETURN = Symbol("return");
export const BREAK = Symbol("break");
export const CONTINUE = Symbol("continue");

export type DeclarationStatement = {
	readonly type: typeof DECLARATION;
	readonly constant: boolean;
	readonly name: string;
	readonly declaredType?: Expression;
	readonly value: Expression;
};

export type AssignmentStatement = {
	readonly type: typeof ASSIGNMENT;
	readonly lhs: Expression;
	readonly rhs: Expression;
};

export type IfElseChainStatement = {
	readonly type: typeof IF_ELSE_CHAIN;
	readonly chain: readonly {
		readonly condition: Expression;
		readonly block: readonly Statement[];
	}[];
	readonly elseBlock?: readonly Statement[];
};

export type WhileLoopStatement = {
	readonly type: typeof WHILE_LOOP;
	readonly condition: Expression;
	readonly block: readonly Statement[];
};

export type ExpressionStatement = {
	readonly type: typeof EXPRESSION;
	readonly expression: Expression;
};

export type ReturnStatement = {
	readonly type: typeof RETURN;
	readonly expression?: Expression;
}

export type BreakStatement = {
	readonly type: typeof BREAK;
};

export type ContinueStatement = {
	readonly type: typeof CONTINUE;
};

export type Statement =
	| DeclarationStatement
	| AssignmentStatement
	| IfElseChainStatement
	| WhileLoopStatement
	| ExpressionStatement
	| ReturnStatement
	| BreakStatement
	| ContinueStatement;

export const DeclarationStatement = (constant: boolean, name: string, declaredType: Expression | undefined, value: Expression): DeclarationStatement => ({
	type: DECLARATION,
	constant,
	name,
	...(declaredType !== undefined ? { declaredType } : {}),
	value
});
export const AssignmentStatement = (lhs: Expression, rhs: Expression): AssignmentStatement => ({ type: ASSIGNMENT, lhs, rhs });
export const IfElseChainStatement = (chain: IfElseChainStatement["chain"], elseBlock: readonly Statement[] | undefined): IfElseChainStatement => ({
	type: IF_ELSE_CHAIN,
	chain,
	...(elseBlock !== undefined ? { elseBlock } : {}),
});
export const WhileLoopStatement = (condition: Expression, block: readonly Statement[]): WhileLoopStatement => ({ type: WHILE_LOOP, condition, block: [...block] });
export const ExpressionStatement = (expression: Expression): ExpressionStatement => ({ type: EXPRESSION, expression });
export const ReturnStatement = (expression: Expression | undefined): ReturnStatement => ({
	type: RETURN,
	...(expression !== undefined ? { expression } : {}),
})
export const BreakStatement: BreakStatement = { type: BREAK };
export const ContinueStatement: ContinueStatement = { type: CONTINUE };
