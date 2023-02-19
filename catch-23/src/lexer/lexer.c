#include "lexer/lexer.h"

#include <stdlib.h>
#include <stdio.h>

void lex(Unit* unit)
{
    TokenList** entry = &unit->tokens;

    while(scanner_is_good(&unit->scan))
    {
        Token token = token_nil();
        bool found_token = false;

        for(size_t i = 0; i < (size_t)TokenCount; i++)
        {
            struct token_info info = token_type_get_info((enum TokenType)i);

            if(info.handler)
            {
                Token tok = info.handler(unit);

                if(tok.type != TokenNill)
                {
                    token = tok;
                    found_token = true;

                    break;
                }
            }
            else if(info.sample)
            {
                struct scanner_iterator it = scanner_current(&unit->scan);

                if(scanner_skip(&unit->scan, match_lexeme(info.sample)))
                {
                    token.type = info.type;
                    token.data = scanner_create_string(it, info.sample);
                    found_token = true;

                    break;
                }
            }
        }

        if(!found_token)
        {
            struct scanner_iterator it = scanner_current(&unit->scan);
            struct scanner_location loc = scanner_location_of(it);

            fprintf(stderr, "error %s:%zu:%zu unknown token '%c'\n", unit->filename, loc.line_num, loc.col_num, it.ch);

            // if no token was matched, then advance to prevent being caught in an infinite loop
            scanner_advance(&unit->scan);

            continue;
        }

        *entry = malloc(sizeof(TokenList));

        (*entry)->token = token;
        entry = &((*entry)->next);
    }

    *entry = NULL;
}
