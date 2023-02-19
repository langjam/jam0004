import { run } from "./interpreter.js";
import { parse } from "./parser.js";
import { tokenize } from "./tokenizer.js";
import fs from "fs/promises";

const USAGE = `Arguments: [FLAGS] FILE
    --dump-tokens    Dump lexer results
    --dump-ast       Dump parser results
    --no-exec        Do not execute`;

const FLAGS = {
	dumpTokens: false,
	dumpAst: false,
	noExec: false,
};

if (process.argv.length < 3) {
	console.log(USAGE);
	process.exit(1);
}

for (let i = 2; i < process.argv.length - 1; ++i) {
	const arg = process.argv[i];
	switch (arg) {
		case "--dump-tokens": FLAGS.dumpTokens = true; break;
		case "--dump-ast": FLAGS.dumpAst = true; break;
		case "--no-exec": FLAGS.noExec = true; break;
		default: console.warn(`Unrecognized flag: ${arg}`); break;
	}
}

const code = await (async () => {
	const path = process.argv[process.argv.length - 1];
	try {
		return await fs.readFile(path, { encoding: "utf-8" });
	} catch (error: any) {
		console.error(`Failed to load file at ${path}: ${error.message}`);
		process.exit(1);
	}
})();

const tokens = (() => {
	try {
		const tokens = tokenize(code);
		if (FLAGS.dumpTokens) {
			console.log(JSON.stringify(tokens, (k, v) => typeof v === "symbol" ? v.description : v, 4));
		}
		return tokens;
	} catch (error: any) {
		console.error(`Tokenizer error: ${error.message}`);
		process.exit(1);
	}
})();

const ast = (() => {
	try {
		const ast = parse(tokens);
		if (FLAGS.dumpAst) {
			console.log(JSON.stringify(ast, (k, v) => typeof v === "symbol" ? v.description : v, 4));
		}
		return ast;
	} catch (error: any) {
		console.error(`Parser error: ${error.message}`);
		process.exit(1);
	}
})();

if (FLAGS.noExec) {
	process.exit(0);
}

try {
	run(ast);
} catch (error: any) {
	console.error(`Runtime error: ${error.message}`);
	process.exit(1);
}
