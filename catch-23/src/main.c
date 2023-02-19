


#include <stdio.h>
#include <stdlib.h>
#include "lexer/lexer.h"
#include "parser/parser.h"

int main(int argc, char* argv[])
{
    DestroyList dl = destroy_list_create();
    
    Unit unit;
    if (!unit_load_from_file("test/sample.catch23", &unit, dl)) {
        fprintf(stderr, "error loading sample file\n");
        exit(-1);
    }
/*
    printf("Input string: %s\n", unit.scan.text);
*/
    lex(&unit);
    printf("Tokens: \n");

    for(TokenList* tok = unit.tokens; tok != NULL; tok = tok->next)
    {
        struct scanner_location loc = token_get_location(tok->token);

        printf("%s:%zu:%zu %i %s\n", unit.filename, loc.line_num, loc.col_num, tok->token.type, tok->token.data.str ? tok->token.data.str : "NULL");
    }
    Parser p = parser_create(unit.tokens);
    Ast dest;
    if (!parser_parse(&p, dl, &dest)) {
        fprintf(stderr, "well, you have an error somewhere. *CAREFULLY* look at the spec and find it! go go go!\n");
        exit(-1);
    }

    ast_print(&dest, 0);

    unit_destroy(&unit);
    destroy_list_destroy(dl);

    return 0;
}