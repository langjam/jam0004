#pragma once

#include "lexer/scanner.h"
#include "unit.h"

// Keep in order from largest to smallest (places handlers at top)
#define TOKEN_MACRO(X) \
    X(TokenNill, NULL, NULL) \
    X(TokenVarIndent, "variable identifier", token_parse_var_identifier) \
    X(TokenNumber, "number", token_parse_number) \
    X(TokenComment, "comment", token_parse_comment) \
    X(TokenBoolean, "#?", NULL) \
    X(TokenThing64, "##", NULL) \
    X(TokenDoubleEqual, "==", NULL) \
    X(TokenShiftLeft, "\"<", NULL) \
    X(TokenShiftRight, "\">", NULL) \
    X(TokenBoolAnd, "&&", NULL) \
    X(TokenBoolOr, "||", NULL) \
    X(TokenIntToFloat, "''", NULL) \
    X(TokenNotEqual, "<>", NULL) \
    X(TokenFloatNotEqual, "><", NULL) \
    X(TokenFloatToInt, "\"", NULL) \
    X(TokenFloatModifier, "'", NULL) \
    X(TokenComplement, "~", NULL) \
    X(TokenThing32, "#", NULL) \
    X(TokenBoolNot, "!", NULL) \
    X(TokenAngBrRight, ">", NULL) \
    X(TokenAngBrLeft, "<", NULL) \
    X(TokenDollar, "$", NULL) \
    X(TokenBitAnd, "&", NULL) \
    X(TokenBitOr, "|", NULL) \
    X(TokenModulo, "%", NULL) \
    X(TokenDiv, "/", NULL) \
    X(TokenHyphen, "-", NULL) \
    X(TokenAdd, "+", NULL) \
    X(TokenColon, ":", NULL) \
    X(TokenSqBrRight, "]", NULL) \
    X(TokenSqBrLeft, "[", NULL) \
    X(TokenStar, "*", NULL)

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
Token token_parse_var_identifier(Unit* unit);

static inline Token token_nil()
{
    return (Token) { TokenNill, {0} };
}
