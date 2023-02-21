#include "lexer/lexer.h"
#include "mem.h"

#define AST_TYPES(X)\
    X(AST_INVALID, "invalid"),\
    X(AST_VAR, "var"),\
    X(AST_FALSE, "false"),\
    X(AST_GOTO, "goto"),\
    X(AST_UNLESS, "unless"),\
    X(AST_LABEL, "label"),\
    X(AST_BREAK, "break"),\
    X(AST_NEVER, "never"),\
    X(AST_DONT, "dont"),\
    X(AST_PREFIX_OPERATOR, "prefix operator"),\
    X(AST_OPERATOR, "operator"),\
    X(AST_PRINT, "print"),\
    X(AST_DEFINE, "define"),\
    X(AST_NUMBER, "number"),\
    X(AST_CALL, "call"),\
    X(AST_ASSIGN, "assign"),\
    X(AST_THING, "thing"),\
    X(AST_ARRAY, "thing array"),\
    X(AST_BLOCK, "block"),\
    X(AST_COUNT, "count")

#define AST_ENUM(ident, name) ident

enum {
    AST_TYPES(AST_ENUM)
}
typedef AstType;

extern char *ast_names[];

struct Ast {
    AstType type;
    Token tok;
    struct Ast *sibling;
    struct Ast *child;
}
typedef Ast;

struct {
    TokenList *token_list;
    DestroyList dl;
}
typedef Parser;

Parser parser_create(TokenList *token_list);
bool parser_parse(Parser *p, DestroyList dl, Ast *dest);

void ast_print(Ast *ast, int indent);
