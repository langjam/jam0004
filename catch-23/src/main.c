#include <stdio.h>
#include "lexer/lexer.h"

int main(int argc, char* argv[])
{
    const char* str = "@in : ## *\\ hello \\*";

    printf("Input string: %s\n", str);

    Unit unit = unit_create("main.catch23", str);

    lex(&unit);

    printf("Tokens: \n");

    for(TokenList* tok = unit.tokens; tok != NULL; tok = tok->next)
    {
        printf("%i %s\n", tok->token.type, tok->token.data.str ? tok->token.data.str : "NULL");
    }

    unit_destroy(&unit);

    return 0;
}
