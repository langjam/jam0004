#pragma once

#include "lexer/scanner.h"

typedef struct Unit
{
    const char* filename;
    Scanner scan;
    struct TokenList* tokens;
} Unit;

Unit unit_create(const char* filename, const char* text);
void unit_destroy(Unit* unit);
