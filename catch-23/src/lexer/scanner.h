#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <string.h>

struct scanner_match
{
    const char* match;
    bool is_lexeme;
};

static inline struct scanner_match match_chars(const char* match)
{
    return (struct scanner_match) { match, false };
}

static inline struct scanner_match match_lexeme(const char* match)
{
    return (struct scanner_match) { match, true };
}

typedef struct Scanner
{
    const char* text;
    size_t len;
    size_t _index;
} Scanner;

static inline Scanner scanner_create(const char* text)
{
    return (Scanner) { text, strlen(text), 0 };
}

struct scanner_iterator
{
    const Scanner* _scanner;
    size_t _index;
    char ch;
};

struct scanner_iterator scanner_current(const Scanner* scanner);
struct scanner_iterator scanner_advance(Scanner* scanner);
struct scanner_iterator scanner_advance_n(Scanner* scanner, ptrdiff_t n);
struct scanner_iterator scanner_peek(const Scanner* scanner);
struct scanner_iterator scanner_peek_n(const Scanner* scanner, ptrdiff_t n);

// a really inefficient (O(n^2)) algorithm for getting the current line and column number
struct scanner_location { size_t line_num; size_t col_num; };
struct scanner_location scanner_location_of(struct scanner_iterator it);

bool scanner_is_good(const Scanner* scanner);
bool scanner_is_match(struct scanner_iterator begin_it, struct scanner_match matcher);
bool scanner_skip(Scanner* scanner, struct scanner_match matcher);
size_t scanner_skip_n(Scanner* scanner, struct scanner_match matcher, size_t n);

struct scanner_string
{
    struct scanner_iterator it;
    char* str; /* a HEAP pointer; may be NULL if input data is invalid; free when done */
    size_t len; /* if str is null, this contains the number characters that were reached */
};

struct scanner_string scanner_create_string(struct scanner_iterator it, const char* str);
void scanner_destroy_string(struct scanner_string str);

/* all these functions will 'give back' characters if an error is detected */
struct scanner_string scanner_split(Scanner* scanner, struct scanner_match prefix, struct scanner_match delimiter);
struct scanner_string scanner_split_exclusively(Scanner* scanner, struct scanner_match matcher);
struct scanner_string scanner_parse_number(Scanner* scanner, int base);
struct scanner_string scanner_parse_string(Scanner* scanner, struct scanner_match quote, struct scanner_match escape);

// Example usage:

// Scanner scan = scanner_create("int i = 0; blah blah blah");
// scanner_skip(&scan, match_lexeme("int"));