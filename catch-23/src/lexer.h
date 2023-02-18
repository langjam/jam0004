#ifndef LEXER_H
#define LEXER_H
#include "tokens.h"
char* scan(const char* source_code, char is_file_path);
token* tokenize(const char* source_code);
#endif
