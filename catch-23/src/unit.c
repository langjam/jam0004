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


