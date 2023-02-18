from enum import Enum


class Error:
    def __init__(self, error_type, message):
        self.error_type = error_type
        self.message = message


class SomeError(Error):
    pass


class TokenType(Enum):
    # STR = "STR"
    INT = "INT"
    FLOAT = "FLOAT"
    # THUMB = "THUMB"
    # INDEX = "INDEX"
    # MIDDLE = "MIDDLE"
    # RING = "RING"
    # PINKY = "PINKY"
    # SOFT = "SOFT"
    # MEDIUM = "MEDIUM"
    # LOUD = "LOUD"
    # COLON = "COLON"
    PLUS = "PLUS"
    MINUS = "MINUS"
    MULTIPLY = "MULTIPLY"
    DIVIDE = "DIVIDE"
    LPAREN = "LPAREN"
    RPAREN = "RPAREN"


class Token:
    def __init__(self, type_: TokenType, value=None):
        self.type = type_
        self.value = value

    def __repr__(self) -> str:
        if self.value:
            return f"{self.type.value}:{self.value}"
        else:
            return f"{self.type.value}"


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
            elif self.current_char == "+":
                tokens.append(Token(TokenType.PLUS))
                self.advance()
            elif self.current_char == "-":
                tokens.append(Token(TokenType.MINUS))
                self.advance()
            elif self.current_char == "*":
                tokens.append(Token(TokenType.MULTIPLY))
                self.advance()
            elif self.current_char == "/":
                tokens.append(Token(TokenType.DIVIDE))
                self.advance()
            elif self.current_char == "(":
                tokens.append(Token(TokenType.LPAREN))
                self.advance()
            elif self.current_char == ")":
                tokens.append(Token(TokenType.RPAREN))
                self.advance()
            else:
                print("Illegal character")
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
                break
            else:
                number_str += self.current_char

            self.advance()

        if dot_found:
            return Token(TokenType.FLOAT, float(number_str))
        else:
            return Token(TokenType.INT, int(number_str))

    def loudness(self):
        loudness_str = ""
        space_found = False

        print(self.current_char)
        while True:
            if self.current_char is None:
                break

            # if self.current_char
            self.advance()


class NumberNode:
    def __init__(self, token):
        self.token = token

    def __repr__(self):
        return f"{self.token}"


class BinaryOperatorNode:
    def __init__(self, left_node, operator_token, right_node):
        self.left_node = left_node
        self.operator_token = operator_token
        self.right_node = right_node

    def __repr__(self):
        return f"({self.left_node}, {self.operator_token}, {self.right_node})"


class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.token_index = -1
        self.current_token = None

        self.advance()

    def advance(self):
        self.token_index += 1
        if self.token_index < len(self.tokens):
            self.current_token = self.tokens[self.token_index]

        return self.current_token

    def parse(self):
        result = self.expr()
        return result

    def factor(self):
        token = self.current_token

        if token.type == TokenType.INT or \
           token.type == TokenType.FLOAT:
            self.advance()
            return NumberNode()

    def term(self):
        return self.binary


simple_program = "7+9*2/(9+2)"
lexer = Lexer("none", simple_program)
print(lexer.tokenize())
