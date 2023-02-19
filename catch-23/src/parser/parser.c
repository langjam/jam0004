#include "parser.h"

Parser parser_create(TokenList *token_list)
{
    return (Parser){token_list};
}

static Token peek_token(Parser *p)
{
    skip_whitespace_tokens(&p);
    if (p->token_list == NULL) {
        return token_nil();
    }
    return p->token_list->token;
}

static TokenList *skip_whitespace_tokens(TokenList *l)
{
    while (l->token.type == TokenWhitespace) {
        l = l->next;
    }

    return l;
}

static Token next_token(Parser *p)
{
    Token tok = peek_token(p);
    p->token_list = p->token_list->next;
    return tok;
}

Ast* parser_parse(Parser *p, DestroyList *dl)
{
    
}
