#include "lexer/tokens.h"

#include <stdio.h>
#include <stdlib.h>

#define ALPHA "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
#define NUMERICAL "0123456789"

// handler format:
// Token token_parse_x(Unit* unit)
// {
//      if basic test conditions fail
//      {
//          return token_nil();
//      }
//      
//      Token token;
//
//      parsing code here..
//
//      return token;
// }

Token token_parse_comment(Unit* unit)
{
    if(!scanner_is_match(scanner_current(&unit->scan), match_lexeme("*\\")))
    {
        return token_nil();
    }

    Token token;

    token.type = TokenComment;

    struct scanner_string comment_text = scanner_split(&unit->scan, match_lexeme("*\\"), match_lexeme("\\*"));

    if(comment_text.str == NULL)
    {
        struct scanner_location loc = scanner_location_of(scanner_current(&unit->scan));

        fprintf(stderr, "error: %s:%i:%i comment has a syntax error\n", unit->filename, loc.line_num, loc.col_num);

        scanner_advance_n(&unit->scan, comment_text.len); /* skip past the erroneous code */
        scanner_destroy_string(comment_text);

        return token_nil();
    }

    token.data = comment_text;

    return token;
}

Token token_parse_number(Unit* unit)
{
    if(!scanner_is_match(scanner_current(&unit->scan), match_chars("-" NUMERICAL)))
    {
        return token_nil();
    }

    Token token;

    token.type = TokenNumber;

    struct scanner_string number_text = scanner_parse_number(&unit->scan, 8); /* use base 8 (octal) */

    if(number_text.str == NULL)
    {
        struct scanner_location loc = scanner_location_of(scanner_current(&unit->scan));

        fprintf(stderr, "error: %s:%i:%i number has a syntax error\n", unit->filename, loc.line_num, loc.col_num);

        scanner_advance_n(&unit->scan, number_text.len); /* skip past the erroneous code */
        scanner_destroy_string(number_text);

        return token_nil();
    }

    token.data = number_text;

    return token;
}

Token token_parse_identifier(Unit* unit)
{
    if(!scanner_is_match(scanner_current(&unit->scan), match_chars(ALPHA)))
    {
        return token_nil();
    }

    Token token;

    token.type = TokenIdentifier;

    struct scanner_string identifier_text = scanner_split_exclusively(&unit->scan, match_chars(ALPHA NUMERICAL));

    if(identifier_text.str == NULL)
    {
        struct scanner_location loc = scanner_location_of(scanner_current(&unit->scan));

        fprintf(stderr, "error: %s:%i:%i variable name has a syntax error\n", unit->filename, loc.line_num, loc.col_num);

        scanner_advance_n(&unit->scan, identifier_text.len); /* skip past the erroneous code */
        scanner_destroy_string(identifier_text);

        return token_nil();
    }

    token.data = identifier_text;

    return token;
}

void token_list_destroy(TokenList* list)
{
    TokenList* entry = list;

    while(entry)
    {
        free(entry);

        entry = entry->next;
    }
}

#define TOKEN_MACRO_SAMPLE_LIST(NAME_, SAMPLE_, HANDLER_) SAMPLE_,

static const char* token_sample_list[] =
{
    TOKEN_MACRO(TOKEN_MACRO_SAMPLE_LIST)
    NULL
};

#define TOKEN_MACRO_HANDLER_LIST(NAME_, SAMPLE_, HANDLER_) HANDLER_,

Token(*token_handler_list[])(Unit* unit) =
{
    TOKEN_MACRO(TOKEN_MACRO_HANDLER_LIST)
    NULL
};

struct token_info token_type_get_info(enum TokenType type)
{
    struct token_info info;

    info.type = type >= 0 && type < TokenCount ? type : TokenNill;
    info.sample = token_sample_list[info.type];
    info.handler = token_handler_list[info.type];

    return info;
}
