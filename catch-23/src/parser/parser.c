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
    while (l && (l->token.type == TokenComment || l->token.type == TokenWhitespace || l->token.type == TokenCr || l->token.type == TokenNewline)) {
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

static bool is_prefix_operator_token_type(enum TokenType tt) {
    return tt == TokenHyphen ||
        tt == TokenTilde ||
        tt == TokenIntToFloat ||
        tt == TokenFloatToInt ||
        tt == TokenFloatNegative ||
        tt == TokenBoolNot;
}

static bool is_infix_operator_token_type(enum TokenType tt) {
    return tt == TokenAdd ||
        tt == TokenHyphen ||
        tt == TokenStar ||
        tt == TokenDiv ||
        tt == TokenModulo ||
        tt == TokenBitOr ||
        tt == TokenBitAnd ||
        tt == TokenShiftLeft ||
        tt == TokenShiftRight ||
        tt == TokenFloatSum ||
        tt == TokenFloatDiff ||
        tt == TokenFloatMul ||
        tt == TokenFloatDiv ||
        tt == TokenAngBrLeft ||
        tt == TokenAngBrRight ||
        tt == TokenEquals ||
        tt == TokenNotEqual ||
        tt == TokenFloatNotEqual ||
        tt == TokenFloatLess ||
        tt == TokenFloatEqual ||
        tt == TokenBoolAnd ||
        tt == TokenBoolOr;
}

static bool parse_var_ident(Parser *p, Token *dest)
{
    checkout(expect_token_type_and_get(p, TokenIdentifier, dest));
    next_token(p);

    if (dest->data.len != 2) {
        return false;
    }

    return true;
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
    checkout(parse_var_ident(p, &name));

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

bool parse_expression(Parser *p, Ast *left);
bool parse_paren(Parser *p, Ast *dest)
{
    next_token(p);
    checkout(parse_expression(p, dest));
    checkout(expect_token_type(p, TokenParenRight));
    next_token(p);
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
        case TokenParenLeft:
            return parse_paren(p, dest);
            *dest = (Ast){
                .type = AST_FALSE,
                .tok = peek_token(p),
            };
            next_token(p);
            return true;
        case TokenDollar: {
            next_token(p);
            Token name;
            checkout(parse_var_ident(p, &name));
            *dest = (Ast){
                .type = AST_VAR,
                .tok = name,
            };
        } return true;
        default:
            return false;
    }
}

bool parse_prefix(Parser *p, Ast *dest)
{

    if (is_prefix_operator_token_type(peek_token(p).type)) {
        Ast curr = (Ast){0}; 
        curr.type = AST_PREFIX_OPERATOR;
        curr.tok = peek_token(p);
        curr.child = alloc_ast(p);
        next_token(p);
        if (curr.tok.type != TokenBoolNot) {
            checkout(parse_prefix(p, curr.child));
        } else {
            bool success = parse_prefix(p, curr.child);
            if (!success) {
                curr.type = AST_FALSE;
                curr.child = NULL;
            }
        }
        *dest = curr;
    } else {
        checkout(parse_atomic(p, dest));
    }

    return true;
}

bool parse_binary(Parser *p, Ast *dest)
{
    Ast *left = alloc_ast(p);
    checkout(parse_prefix(p, left));

    while (is_infix_operator_token_type(peek_token(p).type)) {
        Ast *curr = alloc_ast(p); 
        curr->type = AST_OPERATOR;
        curr->tok = peek_token(p);
        curr->child = left;
        curr->child->sibling = alloc_ast(p);
        next_token(p);
        checkout(parse_prefix(p, curr->child->sibling));
        left = curr;
    }

    *dest = *left;

    return true;
}

bool parse_expression(Parser *p, Ast *left)
{
    return parse_binary(p, left);
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
    checkout(parse_var_ident(p, &name));

    checkout(expect_token_type(p, TokenSqBrLeft));
    next_token(p);

    Tail t = create_tail();
    while (peek_token(p).type != TokenSqBrRight) {
        append_tail(&t, p);

        checkout(parse_expression(p, t.current));

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


bool parse_toplevel(Parser *p, Ast *dest, enum TokenType sentinel);

bool parser_decide_toplevel(Parser *p, Ast *dest)
{
    switch (peek_token(p).type) {
        case TokenAt: 
            return parse_definition(p, dest);
        case TokenDollar: 
            return parse_assignment(p, dest);
        case TokenBreak:
            next_token(p);
            dest->type = AST_BREAK;
            return true;
        case TokenQuestMark: {
            next_token(p);
            Ast *left = alloc_ast(p);
            checkout(parse_paren(p, left))
            Ast *right = alloc_ast(p);

            checkout(expect_token_type(p, TokenCurlyBrLeft));
            next_token(p);
            checkout(parse_toplevel(p, right, TokenCurlyBrRight));
            next_token(p); // Skip Sentinel

            dest->child = left;
            dest->child->sibling = right;
            dest->type = AST_UNLESS;
            return true;
        }
        case TokenGoto:
            next_token(p);
            dest->type = AST_GOTO;
            checkout(expect_token_type_and_get(p, TokenIdentifier, &dest->tok));
            next_token(p);
            return true;
        case TokenLabel:
            next_token(p);
            dest->type = AST_LABEL;
            checkout(expect_token_type_and_get(p, TokenIdentifier, &dest->tok));
            next_token(p);
            return true;
        case TokenDont: 
            next_token(p);
            checkout(expect_token_type(p, TokenCurlyBrLeft));
            next_token(p);
            checkout(parse_toplevel(p, dest, TokenCurlyBrRight));
            next_token(p); // Skip Sentinel
            dest->type = AST_DONT;
            return true;
        case TokenNever: 
            next_token(p);
            checkout(expect_token_type(p, TokenCurlyBrLeft));
            next_token(p);
            checkout(parse_toplevel(p, dest, TokenCurlyBrRight));
            next_token(p); // Skip Sentinel
            dest->type = AST_NEVER;
            return true;
        default:
            return parse_expression(p, dest);
    }
}

bool parse_toplevel(Parser *p, Ast *dest, enum TokenType sentinel)
{
    Tail t = create_tail();

    while (peek_token(p).type != TokenNill && peek_token(p).type != sentinel) {
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
    return parse_toplevel(p, dest, TokenNill);
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