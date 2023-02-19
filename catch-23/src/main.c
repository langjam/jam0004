#include <stdio.h>
#include <stdlib.h>
#include "lexer/lexer.h"

int main(int argc, char* argv[])
{
    DestroyList dl = destroy_list_create();
    
    Unit unit;
    if (!unit_load_from_file("test/sample.catch23", &unit, dl)) {
        fprintf(stderr, "error loading sample file\n");
        exit(-1);
    }

    printf("Input string: %s\n", unit.scan.text);

    lex(&unit);

    printf("Tokens: \n");

    for(TokenList* tok = unit.tokens; tok != NULL; tok = tok->next)
    {
        printf("%i %s\n", tok->token.type, tok->token.data.str ? tok->token.data.str : "NULL");
    }

    unit_destroy(&unit);
    destroy_list_destroy(dl);

    return 0;
}
