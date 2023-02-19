#include <stdio.h>
#include "unit.h"
#include "lexer/tokens.h"

Unit unit_create(const char* filename, const char* text)
{
    Unit unit;

    unit.filename = filename;
    unit.scan = scanner_create(text);
    unit.tokens = NULL;

    return unit;
}

void unit_destroy(Unit* unit)
{
    token_list_destroy(unit->tokens);
}

bool unit_load_from_file(const char *path, Unit* destination, DestroyList dl)
{
    FILE *f = fopen(path, "r");
    if (f == NULL) 
        return false;
    fseek(f, 0, SEEK_END);
    size_t fsz = (size_t) ftell(f);
    fseek(f, 0, SEEK_SET);
    char *input = destroy_list_alloc(dl, (fsz+1)*sizeof(char));
    input[fsz] = 0;
    fread(input, sizeof(char), fsz, f);
    fclose(f);

    *destination = (Unit){
        path,
        scanner_create(input),
        NULL
    };

    return true;
}

