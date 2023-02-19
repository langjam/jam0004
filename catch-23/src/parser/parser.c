#include "parser.h"
#include <stdio.h>

#define checkout(x) if (!(x)) return false;
#define AST_NAMES(ident, name) name

char *ast_names[] = {
    AST_TYPES(AST_NAMES)
};

Parser parser_create(TokenList *token_list)
{
    return (Parser){token_list};
}

static TokenList *skip_whitespace_tokens(TokenList *l)
{
    while (l && (l->token.type == TokenWhitespace || l->token.type == TokenCr || l->token.type == TokenNewline)) {
        l = l->next;
    }

    return l;
}

static Token peek_token(Parser *p)
{
    p->token_list = skip_whitespace_tokens(p->token_list);
    if (p->token_list == NULL) {
        return token_nil();
    }
    return p->token_list->token;
}

static Token next_token(Parser *p)
{
    Token tok = peek_token(p);
    p->token_list = p->token_list->next;
    return tok;
}

bool expect_token_type(Parser *p, enum TokenType tt)
{
    // TODO: Add Error Here.
    return (peek_token(p).type == tt);
}

bool expect_token_type_and_get(Parser *p, enum TokenType tt, Token *dest)
{
    *dest = peek_token(p);
    return expect_token_type(p, tt);
}

Ast *alloc_ast(Parser *p)
{
    Ast *result = destroy_list_alloc(p->dl, sizeof(Ast));
    *result = (Ast){0};
    return result;
}

Ast *copy_ast(Parser *p, Ast ast) 
{
    Ast *result = alloc_ast(p);
    *result = ast;
    return result;
}

static bool parse_type(Parser *p, Ast *dest)
{
    Token t = peek_token(p);
    switch (t.type) {
        case TokenThingArray: 
            *dest = (Ast){.type = AST_ARRAY, .tok = t};
            next_token(p);
            return true;
        case TokenThing: 
            *dest = (Ast){.type = AST_THING, .tok = t};
            next_token(p);
            return true;
        default: 
            return false;
    }
}

static bool parse_definition(Parser *p, Ast *dest)
{
    checkout(expect_token_type(p, TokenAt));
    next_token(p);

    Token name;
    checkout(expect_token_type_and_get(p, TokenIdentifier, &name));
    next_token(p);

    checkout(expect_token_type(p, TokenColon));
    next_token(p);

    Ast *type = alloc_ast(p);
    checkout(parse_type(p, type));

    *dest = (Ast){
        .type = AST_DEFINE,
        .tok = name,
        .child = type
    };
    return true;
}

bool parse_atomic(Parser *p, Ast *dest)
{
    switch (peek_token(p).type) {
        case TokenNumber:
            *dest = (Ast){
                .type = AST_NUMBER,
                .tok = peek_token(p),
            };
            next_token(p);
            return true;
        default:
            return false;
    }
}

struct {
    Ast origin;
    Ast *current;
}
typedef Tail;

Tail create_tail() 
{
    return (Tail){0};
}

void append_tail(Tail *t, Parser *p)
{
    if (t->current == NULL) {
        t->current = &t->origin;
    } else {
        t->current->sibling = alloc_ast(p);
        t->current = t->current->sibling;
    }
}

static bool parse_assignment(Parser *p, Ast *dest)
{
    checkout(expect_token_type(p, TokenDollar));
    next_token(p);

    Token name;
    checkout(expect_token_type_and_get(p, TokenIdentifier, &name));
    next_token(p);

    checkout(expect_token_type(p, TokenSqBrLeft));
    next_token(p);

    Tail t = create_tail();
    while (peek_token(p).type != TokenSqBrRight) {
        append_tail(&t, p);

        checkout(parse_atomic(p, t.current));

        if (peek_token(p).type == TokenSqBrRight) {
            break;
        }
 
        checkout(expect_token_type(p, TokenComma));
        next_token(p);
    }
    next_token(p); // skip ]

    *dest = (Ast){
        .type = AST_ASSIGN,
        .tok = name,
        .child = copy_ast(p, t.origin)
    };
    return true;
}

bool parser_decide_toplevel(Parser *p, Ast *dest)
{
    switch (peek_token(p).type) {
        case TokenAt: 
            return parse_definition(p, dest);
        case TokenDollar: 
            return parse_assignment(p, dest);
        default:
            return parse_atomic(p, dest);
    }
}

bool parse_toplevel(Parser *p, Ast *dest)
{
    Tail t = create_tail();

    while (peek_token(p).type != TokenNill) {
        append_tail(&t, p);
        checkout(parser_decide_toplevel(p, t.current));
    }   

    *dest = (Ast) {
        .type = AST_BLOCK,
        .child = copy_ast(p, t.origin),
    };
    return true;
}

bool parser_parse(Parser *p, DestroyList dl, Ast *dest)
{
    p->dl = dl;

    *dest = (Ast){0};
    return parse_toplevel(p, dest);
}

void ast_print(Ast *ast, int indent)
{
    if (ast == NULL) return;

    printf("%-*s%s :: %s\n", indent*4, "", ast->tok.data.str, ast_names[ast->type]);

    ast_print(ast->child, indent+1);

    if (ast->child)
        for (Ast *sibling = ast->child->sibling; sibling; sibling = sibling->sibling) {
            ast_print(sibling, indent+1);
        }
}
