from enum import Enum
from dataclasses import dataclass
from typing import Optional


# Show the line on which the error happens and then point with arrows
# where the arrow is
# This won't be super accurate as it will always only point out the first
# character of the error, but it is a good start
class Error:
    def __init__(self, position: tuple[str, int, int], error_name, details):
        self.position: tuple[str, int, int] = position
        self.error_name = error_name
        self.details = details

    def show(self):
        error = f"{self.position[0]} {self.position[1]}:{self.position[2]}\n"
        error += f"{self.error_name}: {self.details}\n"
        return error


class IllegalCharacterError(Error):
    def __init__(self, position: tuple[str, int, int], details):
        super().__init__(position, "Illegal character error", details)


class UnkownKeywordError(Error):
    def __init__(self, position: tuple[str, int, int], details):
        super().__init__(position, "Unknown keyword error", details)


class SyntaxError(Error):
    def __init__(self, position: tuple[str, int, int], details):
        super().__init__(position, "Syntax error", details)


class Keyword:
    keywords = ["thumb",
                "index",
                "middle",
                "ring",
                "pinky",
                "soft",
                "medium",
                "loud"
                ]


class TokenType(Enum):
    INT = "INT"
    FLOAT = "FLOAT"
    STRING = "STRING"
    KEYWORD = "KEYWORD"
    COLON = ":"
    EOF = "EOF"
    INDENT = "INDENT"


@dataclass
class Token:
    Type: TokenType
    Value: Optional[str] = None


class Lexer:
    def __init__(self, filename: str, code: str):
        self.filename: str = filename
        self.code: str = code
        self.column: int = -1
        self.prev_column: int = self.column
        self.line_number: int = 1
        self.cursor: int = -1
        self.current_char: Optional[str] = None

        self.advance()

    def advance(self):
        self.cursor += 1
        self.column += 1
        if self.cursor < len(self.code):
            self.current_char = self.code[self.cursor]
            if self.current_char == "\n":
                self.prev_column = self.column
                self.column = 0
                self.line_number += 1
                self.advance()
        else:
            self.current_char = None

    def previous(self):
        self.cursor -= 1
        self.column -= 1

        if self.cursor >= 0:
            self.current_char = self.code[self.cursor]
            if self.current_char == self.column:
                if self.prev_column is None:
                    print("Warn: column cannot be reset")
                else:
                    self.column = self.prev_column
                self.previous()

    def tokenize(self):
        tokens = []

        n = 0
        while self.current_char is not None and n <= 10:
            # if self.current_char not in " \t\n":
            #     print(self.current_char)

            if self.current_char.isdigit():
                ret_value = self.number()
                if isinstance(ret_value, Error):
                    return ret_value.show()
                tokens.append(ret_value)
                self.advance()
            elif self.current_char.isalpha():
                ret_value = self.identify()
                if isinstance(ret_value, Error):
                    return ret_value.show()
                tokens.append(ret_value)
                self.advance()
            elif self.current_char == ":":
                tokens.append(Token(TokenType.COLON))
                self.advance()
            elif self.current_char == '"':
                ret_value = self._string()
                if isinstance(ret_value, Error):
                    return ret_value.show()
                tokens.append(ret_value)
                self.advance()
            # elif "n" in self.current_char:
            #     tokens.append(Token(TokenType.EOF))
            #     self.advance()
            elif self.current_char in " \t":
                tokens.append(Token(TokenType.INDENT))
                self.advance()
            else:
                print(n)
                n += 1

        return tokens

    def number(self):
        number_str = ""
        dot_found = False

        while self.current_char is not None:
            if self.current_char == ".":
                match dot_found:
                    case True:
                        return IllegalCharacterError((self.filename,
                                                      self.line_number,
                                                      self.column),
                                                     "'.'")
                    case False:
                        dot_found = True
                        number_str += "."
            elif self.current_char.isdigit():
                number_str += self.current_char
            elif self.current_char in " \t\n":
                break
            else:
                return IllegalCharacterError((self.filename,
                                              self.line_number,
                                              self.column),
                                             f"'{self.current_char}'")

            self.advance()

        # print(number_str, dot_found)
        if dot_found:
            return Token(TokenType.FLOAT, float(number_str))
        else:
            return Token(TokenType.INT, int(number_str))

    def identify(self):
        curr_str = ""

        while self.current_char is not None:
            if curr_str in Keyword.keywords:
                # self.previous()
                return Token(TokenType.KEYWORD, curr_str)
            elif self.current_char in " \t\n":
                print(self.current_char)
                return UnkownKeywordError((self.filename,
                                           self.line_number,
                                           self.column),
                                          f"'{curr_str}'")
            else:
                curr_str += self.current_char
                self.advance()

        if curr_str in Keyword.keywords:
            # self.previous()
            return Token(TokenType.KEYWORD, curr_str)
        else:
            return UnkownKeywordError((self.filename,
                                       self.line_number,
                                       self.column),
                                      f"'{curr_str}'")

    def _string(self):
        curr_str = ""

        self.advance()
        while self.current_char is not None:
            if self.current_char == '"':
                return Token(TokenType.STRING, str(curr_str))

            curr_str += self.current_char
            self.advance()

        return SyntaxError((self.filename, self.line_number, self.column),
                           "unterminated string literal")


with open("examples/test.tap", 'r') as f:
    simple_program = f.read()

print(simple_program)
lexer = Lexer("none", simple_program)
print(lexer.tokenize())
