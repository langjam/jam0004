from enum import Enum
from dataclasses import dataclass
from typing import Optional
import numpy
import sys


class Error:
    def __init__(self, position: tuple[str, int, int], error_name, details):
        self.position: tuple[str, int, int] = position
        self.error_name = error_name
        self.details = details

    def show(self):
        error = f"{self.position[0]} {self.position[1]}:{self.position[2]}\n"
        error += f"{self.error_name}: {self.details}"
        return error


class IllegalCharacterError(Error):
    def __init__(self, position: tuple[str, int, int], details):
        super().__init__(position, "IllegalCharacterError", details)


class UnkownKeywordError(Error):
    def __init__(self, position: tuple[str, int, int], details):
        super().__init__(position, "UnknownKeywordError", details)


class SyntaxError(Error):
    def __init__(self, position: tuple[str, int, int], details):
        super().__init__(position, "SyntaxError", details)


class IllegalKeywordValuePairError(Error):
    def __init__(self, position: tuple[str, int, int], details):
        super().__init__(position, "IllegalKeywordValueError", details)


class UnexpectedTokenError(Error):
    def __init__(self, position: tuple[str, int, int], details):
        super().__init__(position, "UnexpectedTokenError", details)


class InvalidArgumentNumberError(Error):
    def __init__(self, filename: str, details):
        super().__init__((filename, 0, 0), "InvalidArgumentNumberError", details)


class InvalidOperatorNameError(Error):
    def __init__(self, filename: str, details):
        super().__init__((filename, 0, 0), "InvalidOperatorNameError", details)


class UnkownVariableNameError(Error):
    def __init__(self, filename: str, details):
        super().__init__((filename, 0, 0), "UnkownVariableNameError", details)


class InitializeVariableError(Error):
    def __init__(self, filename: str, details):
        super().__init__((filename, 0, 0), "InitializeVariableError", details)


class Keyword:
    keywords = ["thumb",
                "index",
                "middle",
                "ring",
                "pinky",
                ]

    modifiers = ["soft",
                 "medium",
                 "hard"
                 ]

    end = ["end"]


class TokenType(Enum):
    INT = "INT"
    FLOAT = "FLOAT"
    STRING = "STRING"
    KEYWORD = "KEYWORD"
    MODIFIER = "MODIFIER"
    END = "END"
    COLON = "COLON"


@dataclass
class Token:
    Type: TokenType
    Position: tuple[str, int, int]
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
        self.new_line = False

        self.advance()

    def advance(self):
        self.cursor += 1
        self.column += 1
        if self.new_line:
            self.prev_column = self.column
            self.column = 0
            self.line_number += 1
            self.new_line = False

        if self.cursor < len(self.code):
            self.current_char = self.code[self.cursor]
            if self.current_char == "\n":
                self.new_line = True
        else:
            self.current_char = None

    def tokenize(self):
        tokens = []

        n = 0
        while self.current_char is not None and n <= 10:
            if self.cursor+1 < len(self.code) and \
               self.current_char == "/" and self.code[self.cursor+1] == "/":
                while self.current_char != "\n" and \
                      self.current_char is not None:
                    self.advance()
            elif self.current_char.isdigit():
                ret_value = self.number()
                if isinstance(ret_value, Error):
                    return ret_value
                tokens.append(ret_value)
            elif self.current_char.isalpha():
                ret_value = self.identify()
                # print(tokens)
                if isinstance(ret_value, Error):
                    return ret_value
                tokens.append(ret_value)
            elif self.current_char == ":":
                tokens.append(Token(TokenType.COLON, (self.filename,
                                    self.line_number, self.column)))
                self.advance()
            elif self.current_char == '"':
                ret_value = self._string()
                if isinstance(ret_value, Error):
                    return ret_value
                tokens.append(ret_value)
                self.advance()
            elif self.current_char in " \t\n":
                self.advance()
            else:
                print(n, "Illegal character error")
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

        if dot_found:
            return Token(TokenType.FLOAT, (self.filename,
                         self.line_number, self.column), float(number_str))
        else:
            return Token(TokenType.INT, (self.filename,
                         self.line_number, self.column), int(number_str))

    def identify(self):
        curr_str = ""

        while self.current_char is not None:
            if curr_str in Keyword.keywords and self.current_char in " \t\n":
                # self.previous()
                return Token(TokenType.KEYWORD, (self.filename,
                             self.line_number, self.column), curr_str)
            elif curr_str in Keyword.modifiers and self.current_char in " \t\n:":
                return Token(TokenType.MODIFIER, (self.filename,
                             self.line_number, self.column), curr_str)
            elif curr_str in Keyword.end and self.current_char in " \t\n":
                return Token(TokenType.END, (self.filename,
                             self.line_number, self.column))
            elif self.current_char in " \t\n":
                return UnkownKeywordError((self.filename,
                                           self.line_number,
                                           self.column),
                                          f" '{curr_str}'")
            else:
                curr_str += self.current_char
                self.advance()

        if curr_str in Keyword.keywords:
            # self.previous()
            return Token(TokenType.KEYWORD, (self.filename,
                         self.line_number, self.column), curr_str)
        elif curr_str in Keyword.modifiers:
            return Token(TokenType.MODIFIER, (self.filename,
                         self.line_number, self.column), curr_str)
        elif curr_str in Keyword.end:
            return Token(TokenType.END, (self.filename,
                         self.line_number, self.column))
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
                return Token(TokenType.STRING, (self.filename,
                             self.line_number, self.column), str(curr_str))

            curr_str += self.current_char
            self.advance()

        return SyntaxError((self.filename, self.line_number, self.column),
                           "unterminated string literal")


class Parser:
    def __init__(self, filename: str, tokens):
        self.filename: str = filename
        self.tokens = tokens
        self.token_index: int = -1
        self.current_token = None

        self.advance()

    def advance(self):
        self.token_index += 1
        if self.token_index < len(self.tokens):
            self.current_token = self.tokens[self.token_index]
        else:
            self.current_token = None
        return self.current_token

    def parse(self):
        ast = []

        while self.current_token is not None:
            # print(self.current_token.Type)
            if self.current_token.Type == TokenType.KEYWORD:
                ret_value = self.uncover()
                if isinstance(ret_value, Error):
                    return ret_value.show()
                ast.append(ret_value)
            elif self.current_token.Type == "":
                pass
            self.advance()

        return ast

    def uncover(self):
        cur_ast = []

        previous_token = self.current_token
        expected_token_type = None

        self.advance()
        while self.current_token is not None:
            if expected_token_type is not None:
                if self.current_token.Type == expected_token_type:
                    expected_token_type = None
                    if self.current_token.Type == TokenType.COLON:
                        end_found = False
                        while self.current_token is not None:
                            if self.current_token.Type == TokenType.END:
                                end_found = True
                                break
                            if self.current_token.Type == TokenType.STRING:
                                cur_ast.append(self.current_token.Value)
                            elif self.current_token.Type == TokenType.INT or \
                                 self.current_token.Type == TokenType.FLOAT:
                                cur_ast.append(self.current_token.Value)
                            elif self.current_token.Type == TokenType.KEYWORD:
                                ret_value = self.uncover()
                                if isinstance(ret_value, Error):
                                    return ret_value
                                cur_ast.append(ret_value)
                            self.advance()
                        if not end_found and self.current_token is not None:
                            return SyntaxError(self.current_token.Position,
                                               "missing 'END' token")
                        else:
                            break
                else:
                    # This goes wrong with colons as colons have a value of None
                    return UnexpectedTokenError(self.current_token.Position,
                                                f"'{self.current_token.Type.value}'")
            elif previous_token.Type == TokenType.KEYWORD and \
                 self.current_token.Type == TokenType.MODIFIER:
                keyword_value_pair = f"{previous_token.Value} {self.current_token.Value}"
                match keyword_value_pair:
                    case "thumb soft":
                        cur_ast.append("set_variable")
                    case "thumb medium":
                        cur_ast.append("get_variable")
                    case "thumb hard":
                        cur_ast.append("create_variable")
                    case "index soft":
                        cur_ast.append("print")
                    case "index medium":
                        cur_ast.append("get_user_value")
                    case "index hard":
                        cur_ast.append("mathematical_operation")
                    case "middle soft":
                        cur_ast.append("show_info")
                    case "middle medium":
                        cur_ast.append("show_warning")
                    case "middle hard":
                        cur_ast.append("show_error")
                    case "ring soft":
                        cur_ast.append("loop")
                    case "ring medium":
                        cur_ast.append("break")
                    case "ring hard":
                        print("ring hard is not yet implemented")
                    case "pinky soft":
                        cur_ast.append("if")
                    case "pinky medium":
                        cur_ast.append("then")
                    case "pinky hard":
                        cur_ast.append("else")
                    case other:
                        return IllegalKeywordValuePairError(self.current_token.Position,
                                                            f"'{keyword_value_pair}'")

                expected_token_type = TokenType.COLON
                self.advance()
            else:
                print(f"ELSE: {self.current_token}")
                self.advance()

        return cur_ast


class Variables:
    Name: str
    Value: str  # I set it to str because it has to have a type but it can be any type


class Interpreter:
    def __init__(self, filename, ast):
        self.filename = filename
        self.ast = ast
        self.variables = {}
        self._if_value = None
        self.in_loop = False

    def parse(self):
        for value in self.ast:
            ret_value = self.check_todo(value)
            if isinstance(ret_value, Error):
                return ret_value

    def check_todo(self, value):
        idx = 0

        if isinstance(value, Error):
            return value
        elif value is None:
            return None
        elif value[0] == "create_variable":
            idx += 1
            if not idx < len(value):
                return InvalidArgumentNumberError(self.filename,
                                                  "Invalid number of args for thumb hard")
            return self.create_variable(value[idx])

        elif value[0] == "set_variable":
            idx += 1
            if not idx+1 < len(value):
                return InvalidArgumentNumberError(self.filename,
                                                  "Invalid number of args for thumb soft")
            new_values = value[2:]
            set_value = None
            for v in new_values:
                if isinstance(v, list):
                    set_value = self.check_todo(v)
                    if isinstance(set_value, Error):
                        return set_value 
                else:
                    set_value = v

            return self.set_variable(value[idx], set_value)

        elif value[0] == "get_variable":
            idx += 1
            if not idx < len(value):
                return InvalidArgumentNumberError(self.filename,
                                                  "Invalid number of args for thumb medium")
            return self.get_variable(value[idx])

        elif value[0] == "print":
            self.print_func(value, "print")
        elif value[0] == "get_user_value":
            if len(value) > 1:
                return input(value[1])
            else:
                return input()

        elif value[0] == "mathematical_operation":
            if len(value) < 3:
                return InvalidArgumentNumberError(self.filename,
                                                  "Invalid number of args for index hard")
            operator = value[1]
            new_values = value[2:]
            nums = []
            str_operator = False
            for v in new_values:
                if isinstance(v, list):
                    ret_value = self.check_todo(v)
                    if isinstance(ret_value, Error):
                        return ret_value
                    elif isinstance(ret_value, str) and not str_operator:
                        str_operator = True
                    nums.append(ret_value)
                else:
                    # Change this so it also changes str that are actual int or float
                    if isinstance(v, str) and not str_operator:
                        str_operator = True
                    nums.append(v)

            if str_operator:
                match operator:
                    case "add":
                        answer = str(nums[0])
                        rest = nums[1:]
                        for i in rest:
                            answer += str(i)
                        return answer
                    case other:
                        return InvalidOperatorNameError(self.filename, f"'{operator}' for type 'str'")
            else:
                match operator:
                    case "add":
                        return sum(nums)
                    case "sub":
                        answer = nums[0]
                        rest = nums[1:]
                        for i in rest:
                            answer = answer-i
                        return answer
                    case "mul":
                        return numpy.prod(nums)
                    case "div":
                        answer = nums[0]
                        rest = nums[1:]
                        for i in rest:
                            answer = answer/i
                        return answer
                    case other:
                        # print("Reporting error")
                        return InvalidOperatorNameError(self.filename, f"'{operator}'")

        elif value[0] == "show_info":
            self.print_func(value, "info")

        elif value[0] == "show_warning":
            self.print_func(value, "warning")

        elif value[0] == "show_error":
            self.print_func(value, "error")

        elif value[0] == "loop":
            self.in_loop = True
            while self.in_loop:
                rest = value[1:]
                for v in rest:
                    ret_value = self.check_todo(v)
                    if isinstance(ret_value, Error):
                        return ret_value
                    elif ret_value == "break":
                        break

        elif value[0] == "break":
            self.in_loop = False
            return "break"

        elif value[0] == "if":
            idx += 1
            if not idx+1 < len(value):
                return InvalidArgumentNumberError(self.filename,
                                                  "Invalid number of args for create variable")

            new_values = value[1:]
            parts = []
            for v in new_values:
                if isinstance(v, list):
                    ret_value = self.check_todo(v)
                    if isinstance(ret_value, Error):
                        return ret_value
                    parts.append(ret_value)
                else:
                    if isinstance(v, Error):
                        return v
                    parts.append(v)
            self._if_value = self._if(parts[0], parts[1])

        elif value[0] == "then":
            if self._if_value is None:
                return UnexpectedTokenError((self.filename, 0, 0), "need 'IF' before 'THEN'")
            elif self._if_value is True:
                new_values = value[1:]
                for v in new_values:
                    ret_value = self.check_todo(v)
                    if isinstance(ret_value, Error):
                        return ret_value

        elif value[0] == "else":
            if self._if_value is None:
                return UnexpectedTokenError((self.filename, 0, 0), "need 'IF' before 'ELSE'")
            elif self._if_value is False:
                new_values = value[1:]
                for v in new_values:
                    ret_value = self.check_todo(v)
                    if isinstance(ret_value, Error):
                        return ret_value

        else:
            return None
            # return UnexpectedTokenError((self.filename, 0, 0), f"'{value}'")

    def print_func(self, value, type_):
        new_values = value[1:]
        to_print = []
        for v in new_values:
            if isinstance(v, list):
                to_print.append(self.check_todo(v))
            else:
                to_print.append(v)

        match type_:
            case "print":
                self._print(to_print)
            case other:
                self._middle(type_, to_print)
        
    def create_variable(self, var_name):
        if var_name in self.variables:
            return InitializeVariableError(self.filename,
                                           f"cannot initialize variable '{var_name}' twice")
        else:
            self.variables[var_name] = None

    def set_variable(self, var_name, value):
        if var_name in self.variables:
            self.variables[var_name] = value
        else:
            return UnkownVariableNameError(self.filename, f"'{var_name}'")

    def get_variable(self, var_name):
        if var_name in self.variables:
            return self.variables[var_name]
        else:
            return UnkownVariableNameError(self.filename, f"'{var_name}'")

    def _print(self, to_print):
        for item in to_print:
            print(item)

    def _middle(self, type_, to_print):
        for item in to_print:
            print(f"{type_}:", item)

    def _if(self, part1, part2):
        if part1 == part2:
            return True
        else:
            return False


if __name__ == "__main__":
    file_name = str(sys.argv[1])
    with open(file_name, 'r') as f:
        simple_program = f.read()

    lexer = Lexer(file_name, simple_program)
    tokens = lexer.tokenize()
    if not isinstance(tokens, Error):
        parser = Parser(file_name, tokens)
        ast = parser.parse()
        if not isinstance(parser, Error):
            interpreter = Interpreter(file_name, ast)
            result = interpreter.parse()
            if isinstance(result, Error):
                print(result.show())
        else:
            print(ast.show())
    else:
        print(tokens.show())
