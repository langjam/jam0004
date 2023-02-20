export type Function = {
    name: string;
    description: string;
    usage: string;
}

export type Variable = {
    name: string;
    value: string;
    description: string;
}

export type Doc = {
    name: string;
    description: string;
    functions: Function[];
    variables: Variable[];
}

export function parseDoc(doc: string): Doc {
    const lines = doc.split('\n');

    // consume preamble
    let name = lines.shift();
    let description = lines.shift();

    while (lines[0] == '') {
        lines.shift();
    }

    let blocks: string[][] = [];
    let block = [];
    for (const line of lines) {
        if (line == '') {
            blocks.push(block);
            block = [];
        } else {
            block.push(line);
        }
    }

    // remove any empty blocks
    blocks = blocks.filter(block => block.length > 0) as string[][];

    // parse blocks
    let functions: Function[] = [];
    let variables: Variable[] = [];

    for (const block of blocks) {
        if (block.length == 2) {
            // variable
            const [name, value] = block[0].split(' = ');
            variables.push({
                name,
                value,
                description: block[1]
            });
        } else if (block.length == 3) {
            // function
            functions.push({
                name: block[0],
                description: block[2],
                usage: block[1]
            });
        }
    }

    return {
        name,
        description,
        functions,
        variables
    }
}