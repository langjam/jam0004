from enum import Enum


class TokenType(Enum):
    STR = "STR"
    INT = "INT"
    FLOAT = "FLOAT"
    THUMB = "THUMB"
    INDEX = "INDEX"
    MIDDLE = "MIDDLE"
    RING = "RING"
    PINKY = "PINKY"
    SOFT = "SOFT"
    MEDIUM = "MEDIUM"
    LOUD = "LOUD"
    COLON = "COLON"


class Token:
    def __init__(self, type_: TokenType, value):
        self.type = type_
        self.value = value

    def __repr__(self) -> str:
        return f"{self.type}:{self.value}"


class Lexer:
    def __init__(self, filename: str, text: str):
        self.filename = filename
        self.text = text
        self.line_number = 1
        self.cursor = -1
        self.current_char = None

        self.advance()

    def advance(self) -> None:
        self.cursor += 1
        self.current_char = self.text[self.cursor] if \
            self.cursor < len(self.text) else None

        if self.current_char == "\n":
            self.line_number += 1
            self.advance()

    def tokenize(self) -> tuple[list[Token], None]:
        tokens: list[Token] = []

        while self.current_char is not None:
            if self.current_char.isdigit():
                tokens.append(self.number())

            self.advance()

        return tokens, None

    def number(self):
        number_str = ""
        dot_found = False

        while True:
            if self.current_char is None:
                break

            if self.current_char == ".":
                match dot_found:
                    case False:
                        dot_found = True
                        number_str += "."
                    case True:
                        print("Error: To many dots")
                        return "Loud Middlefinger tap: Error msg"
            elif self.current_char in " \t":
                break
            elif not self.current_char.isdigit() and self.current_char != "_":
                print("Error: unkown character")
                return "Loud Middlefinger tap: Error msg"
            else:
                number_str += self.current_char

            self.advance()

        if dot_found:
            return Token(TokenType.FLOAT, float(number_str))
        else:
            return Token(TokenType.INT, int(number_str))


simple_program = "\n123456789 \n9.87"
lexer = Lexer("none", simple_program)
print(lexer.tokenize())
