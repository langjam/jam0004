#pragma once

#include "lexer/scanner.h"
#include "mem.h"

typedef struct Unit
{
    const char* filename;
    Scanner scan;
    struct TokenList* tokens;
} Unit;

Unit unit_create(const char* filename, const char* text);
bool unit_load_from_file(const char *path, Unit*, DestroyList dl);
void unit_destroy(Unit* unit);
