#include "lexer/scanner.h"

#include <stdlib.h>
#include <ctype.h>

static struct scanner_iterator create_iterator(const Scanner* scanner, ptrdiff_t diff)
{
    size_t index = scanner->_index + diff;
    char ch = index < scanner->len ? scanner->text[index] : 0;

    return (struct scanner_iterator) { scanner, index, ch };
}

// TODO: improve preformance of this function
struct scanner_location scanner_location_of(struct scanner_iterator it)
{
    struct scanner_location loc = { 1, 1 };

    if(it._index >= it._scanner->len)
    {
        return loc;
    }

    for(size_t i = 0; i < it._index; i++)
    {
        if(it._scanner->text[it._scanner->_index] == '\n')
        {
            loc.line_num++;
            loc.col_num = 0;
        }

        loc.col_num++;
    }

    return loc;
}

struct scanner_iterator scanner_current(const Scanner* scanner)
{
    return create_iterator(scanner, 0);
}

struct scanner_iterator scanner_advance(Scanner* scanner)
{
    struct scanner_iterator it = create_iterator(scanner, 0);

    scanner->_index++;

    return it;
}

struct scanner_iterator scanner_advance_n(Scanner* scanner, ptrdiff_t n)
{
    struct scanner_iterator it = create_iterator(scanner, 0);

    scanner->_index += n;

    return it;
}

struct scanner_iterator scanner_peek(const Scanner* scanner)
{
    return create_iterator(scanner, 1);
}

struct scanner_iterator scanner_peek_n(const Scanner* scanner, ptrdiff_t n)
{
    return create_iterator(scanner, n);
}

bool scanner_is_good(const Scanner* scanner)
{
    return scanner->_index < scanner->len;
}

bool scanner_is_match(struct scanner_iterator begin_it, struct scanner_match matcher)
{
    size_t matcher_len = strlen(matcher.match);
    bool result = false;

    if(matcher.is_lexeme)
    {
        result = true;
        
        for(size_t i = 0; i < matcher_len; i++)
        {
            size_t text_index = begin_it._index + i;
            
            if(text_index >= begin_it._scanner->len)
            {
                result = false;

                break;
            }

            char text_ch = begin_it._scanner->text[text_index];
            char match_ch = matcher.match[i];

            if(text_ch != match_ch)
            {
                result = false;

                break;
            }
        }
    }
    else
    {
        for(size_t i = 0; i < matcher_len; i++)
        {
            if(begin_it.ch == matcher.match[i])
            {
                result = true;

                break;
            }
        }
    }

    return result;
}

bool scanner_skip(Scanner* scanner, struct scanner_match matcher)
{
    if(scanner_is_good(scanner) && scanner_is_match(scanner_current(scanner), matcher))
    {
        scanner->_index += matcher.is_lexeme ? strlen(matcher.match) : 1;

        return true;
    }

    return false;
}

size_t scanner_skip_n(Scanner* scanner, struct scanner_match matcher, size_t n)
{
    size_t match_len = matcher.is_lexeme ? strlen(matcher.match) : 1;
    size_t count = 0;

    while(scanner_is_good(scanner) && scanner_is_match(scanner_current(scanner), matcher) && count <= n)
    {
        scanner->_index += match_len;

        ++count;
    }

    return count;
}

struct scanner_string scanner_create_string(struct scanner_iterator it, const char* str)
{
    size_t len = strlen(str);
    char* buff = malloc((len + 1) * sizeof(char));

    if(buff)
    {
        strncpy(buff, str, len + 1);
    }

    return (struct scanner_string) { it, buff, len };
}

void scanner_destroy_string(struct scanner_string str)
{
    if(str.str)
    {
        free(str.str);
    }
}

static inline struct scanner_string scanner_split_impl(Scanner* scanner, struct scanner_match prefix, struct scanner_match matcher, bool is_exclusive)
{
    size_t matcher_len = strlen(matcher.match);
    size_t old_index = scanner->_index;

    if(!is_exclusive && !scanner_skip(scanner, prefix))
    {
        return (struct scanner_string) { scanner_current(scanner), NULL, 0 };
    }

    while(scanner_is_good(scanner))
    {
        if(matcher_len != 0 && is_exclusive)
        {
            if(!scanner_is_match(scanner_current(scanner), matcher))
            {
                break;
            }
        }
        else if(matcher_len != 0 && !is_exclusive)
        {
            if(scanner_is_match(scanner_current(scanner), matcher))
            {
                break;
            }
        }

        ++scanner->_index;
    }

    if(!is_exclusive && !scanner_skip(scanner, matcher))
    {
        // invalid split, give back
        scanner->_index = old_index;

        return (struct scanner_string) { scanner_current(scanner), NULL, scanner->_index - old_index };
    }

    if(old_index > scanner->len || scanner->_index > scanner->len)
    {
        return (struct scanner_string) { scanner_current(scanner), NULL, 0 };
    }

    size_t len = scanner->_index - old_index;
    char* buff = malloc((len + 1) * sizeof(char));

    if(!buff) return (struct scanner_string) { scanner_current(scanner), NULL, len };

    memcpy(buff, &scanner->text[old_index], len);

    buff[len] = 0;

    return (struct scanner_string) { scanner_current(scanner), buff, len };
}

struct scanner_string scanner_split(Scanner* scanner, struct scanner_match prefix, struct scanner_match delimiter)
{
    return scanner_split_impl(scanner, prefix, delimiter, false);
}

struct scanner_string scanner_split_exclusively(Scanner* scanner, struct scanner_match matcher)
{
    return scanner_split_impl(scanner, (struct scanner_match) {0}, matcher, true);
}

struct scanner_string scanner_parse_number(Scanner* scanner, int base)
{
    static const char digits[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    size_t old_index = scanner->_index;

    if(base <= 0 || base > (sizeof(digits) / sizeof(digits[0])))
    {
        return (struct scanner_string) { scanner_current(scanner), NULL, 0 };
    }

    scanner_skip(scanner, match_chars("-"));

    if(scanner_skip(scanner, match_lexeme("0x")) || scanner_skip(scanner, match_lexeme("0X")))
    {
        base = 16;
    }
    else if(scanner_skip(scanner, match_lexeme("0o")) || scanner_skip(scanner, match_lexeme("0O")))
    {
        base = 8;
    }
    else if(scanner_skip(scanner, match_lexeme("0b")) || scanner_skip(scanner, match_lexeme("0B")))
    {
        base = 2;
    }

    while(scanner_is_good(scanner))
    {
        bool is_digit = false;

        for(size_t i = 0; i < base; i++)
        {
            if(tolower(digits[i]) == scanner->text[scanner->_index])
            {
                is_digit = true;

                break;
            }
        }

        if(!is_digit && scanner->text[scanner->_index] != '.')
        {
            break;
        }

        ++scanner->_index;
    }

    if(old_index > scanner->len || scanner->_index > scanner->len)
    {
        return (struct scanner_string) { scanner_current(scanner), NULL, 0 };
    }

    size_t len = scanner->_index - old_index;
    char* buff = malloc((len + 1) * sizeof(char));

    if(!buff) return (struct scanner_string) { NULL, len };

    memcpy(buff, &scanner->text[old_index], len);

    buff[len] = 0;

    return (struct scanner_string) { scanner_current(scanner), buff, len };
}

struct scanner_string scanner_parse_string(Scanner* scanner, struct scanner_match quote, struct scanner_match escape)
{
    size_t old_index = scanner->_index;
    char initial_quote = scanner_current(scanner).ch;

    if(!scanner_skip(scanner, quote))
    {
        return (struct scanner_string) { scanner_current(scanner), NULL, 0 };
    }

    while(scanner_is_good(scanner))
    {
        if(scanner_is_match(scanner_current(scanner), quote))
        {
            break;
        }
        
        scanner_skip(scanner, escape);

        ++scanner->_index;
    }

    if(quote.is_lexeme ? !scanner_skip(scanner, quote) :
       !scanner_skip(scanner, match_chars(&initial_quote))) /* to prevent using different quote types */
    {
        // invalid string, give back
        scanner->_index = old_index;

        return (struct scanner_string) { scanner_current(scanner), NULL, 0 };
    }

    if(old_index > scanner->len || scanner->_index > scanner->len)
    {
        return (struct scanner_string) { scanner_current(scanner), NULL, 0 };
    }

    size_t len = scanner->_index - old_index;
    char* buff = malloc((len + 1) * sizeof(char));

    if(!buff) return (struct scanner_string) { scanner_current(scanner), NULL, len };

    memcpy(buff, &scanner->text[old_index], len);

    buff[len] = 0;

    return (struct scanner_string) { scanner_current(scanner), buff, len };
}
