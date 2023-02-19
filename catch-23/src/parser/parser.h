#include "lexer/lexer.h"
#include "mem.h"

struct Ast {
    Token tok;
    struct Ast *sibling;
    struct Ast *child;
}
typedef Ast;

struct {
    TokenList *token_list;
}
typedef Parser;

Parser parser_create(TokenList *token_list);
Ast* parser_parse(Parser *p, DestroyList *dl);