#pragma once

#include "lexer/scanner.h"
#include "unit.h"

// Keep in order from largest to smallest (place handlers at top)
#define TOKEN_MACRO(X) \
    X(TokenNill, NULL, NULL) \
    X(TokenIdentifier, "identifier", token_parse_identifier) \
    X(TokenHyphen, "-", NULL) \
    X(TokenNumber, "number", token_parse_number) \
    X(TokenComment, "comment", token_parse_comment) \
    X(TokenThingArray, "#[]", NULL) \
    X(TokenThing, "#", NULL) \
    X(TokenFloatNegative, "'-", NULL) \
    X(TokenFloatEqual, "'=", NULL) \
    X(TokenDoubleEqual, "==", NULL) \
    X(TokenFloatLess, "'<", NULL) \
    X(TokenFloatMore, "'>", NULL) \
    X(TokenShiftLeft, "\"<", NULL) \
    X(TokenShiftRight, "\">", NULL) \
    X(TokenBoolAnd, "&&", NULL) \
    X(TokenBoolOr, "||", NULL) \
    X(TokenFloatSum, "'+", NULL) \
    X(TokenFloatDiff, "'-", NULL) \
    X(TokenFloatMul, "'*", NULL) \
    X(TokenFloatDiv, "'/", NULL) \
    X(TokenIntToFloat, "''", NULL) \
    X(TokenNotEqual, "<>", NULL) \
    X(TokenFloatNotEqual, "><", NULL) \
    X(TokenArrowLeft, "<~", NULL) \
    X(TokenArrowRight, "~>", NULL) \
    X(TokenAgainst, ";;", NULL) \
    X(TokenDont, ":;", NULL) \
    X(TokenNever, "::", NULL) \
    X(TokenFloatToInt, "\"", NULL) \
    X(TokenSingleQuote, "'", NULL) \
    X(TokenThing32, "#", NULL) \
    X(TokenBoolNot, "!", NULL) \
    X(TokenAngBrRight, ">", NULL) \
    X(TokenAngBrLeft, "<", NULL) \
    X(TokenDollar, "$", NULL) \
    X(TokenBitAnd, "&", NULL) \
    X(TokenBitOr, "|", NULL) \
    X(TokenModulo, "%", NULL) \
    X(TokenDiv, "/", NULL) \
    X(TokenAdd, "+", NULL) \
    X(TokenSqBrRight, "]", NULL) \
    X(TokenSqBrLeft, "[", NULL) \
    X(TokenStar, "*", NULL) \
    X(TokenAt, "@", NULL) \
    X(TokenCaret, "^", NULL) \
    X(TokenParenLeft, "(", NULL) \
    X(TokenParenRight, ")", NULL) \
    X(TokenCurlyBrLeft, "{", NULL) \
    X(TokenCurlyBrRight, "}", NULL) \
    X(TokenComma, ",", NULL) \
    X(TokenPeriod, ".", NULL) \
    X(TokenColon, ":", NULL) \
    X(TokenSemicolon, ";", NULL) \
    X(TokenQuestMark, "?", NULL) \
    X(TokenEquals, "=", NULL) \
    X(TokenTilde, "~", NULL) \
    X(TokenWhitespace, " ", NULL) \
    X(TokenNewline, "\n", NULL) \
    X(TokenCr, "\r", NULL)

#define TOKEN_MACRO_ENUM(NAME_, SAMPLE_, HANDLER_) NAME_,

enum TokenType
{
    TOKEN_MACRO(TOKEN_MACRO_ENUM)
    TokenCount
};

typedef struct Token
{
    enum TokenType type;
    struct scanner_string data;
} Token;

typedef struct TokenList
{
    Token token;
    struct TokenList* next;
} TokenList;

void token_list_destroy(TokenList* list);

struct token_info
{
    enum TokenType type;
    const char* sample;
    Token(*handler)(Unit* unit);
};

struct token_info token_type_get_info(enum TokenType type);

static inline void token_destroy(Token token)
{
    scanner_destroy_string(token.data);
}

Token token_parse_comment(Unit* unit);
Token token_parse_number(Unit* unit);
Token token_parse_identifier(Unit* unit);

static inline Token token_nil()
{
    return (Token) { TokenNill };
}
