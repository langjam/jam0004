def tokenizer(parser: list[tuple[str, str]]):
    print(parser)


def parser(program_str: str) -> list[tuple[str, str]]:
    curr_str = ""
    cursor = 0

    tokens = []

    while (cursor < len(program_str)):
        curr_str += program_str[cursor]

        match curr_str:
            case "print":
                tokens.append(("keyword", "PRINT"))
                curr_str = ""
                cursor += 1
                if program_str[cursor] != "(":
                    raise TypeError("A print statement must be followed by a left paren")
                tokens.append(("symbol", "LPAREN"))
                cursor += 1

                while True:
                    curr_str = curr_str + program_str[cursor]
                    if curr_str == '"':
                        tokens.append(("symbol", "QUOTE"))
                        cursor += 1
                        curr_str = ""
                        while True:
                            curr_str = curr_str + program_str[cursor]
                            if '"' in curr_str:
                                tokens.append(("type", "STRING"))
                                tokens.append(("symbol", "QUOTE"))
                                curr_str = ""
                                break
                            cursor += 1

                        cursor += 1
                        if program_str[cursor] == ")":
                            tokens.append(("sybmol", "RPAREN"))
                            break
                        raise TypeError("You need to close the print statement")
        cursor += 1

    return tokens


program_str = 'print("Hello World!")print("Hello World")'

if __name__ == "__main__":
    parser = parser(program_str)

    tokenizer(parser)
