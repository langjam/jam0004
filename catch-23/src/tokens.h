#ifndef TOKENS_H
#define TOKENS_H

typedef enum {
    
    // types
    THING32,
    THING64,
    BOOLEAN,
    
    // operators
    INT_ADD,
    INT_MINUS,
    INT_MULT,
    INT_DIV,
    INT_MOD,
    INT_BOR, // bitwise or
    INT_BAND, // bitwise and
    INT_RSHIFT,
    INT_LSHIFT,
    INT_COMP, // complement 1
    INT_NEG,
    INT_LOWER,
    INT_GREATER,
    INT_EQUAL,
    INT_DIFFERENT,
    CAST_FLOAT,
    CAST_INT,
    FLOAT_ADD,
    FLOAT_MINUS,
    FLOAT_MULT,
    FLOAT_DIV,
    FLOAT_NEG,
    FLOAT_LOWER,
    FLOAT_GREATER,
    FLOAT_EQUAL,
    FLOAT_DIFFERENT,
    OR,
    AND,
    NOT,
    ASSIGN,
    
    // statements
    RETURN,
    BREAK,
    GOTO,
    NEVER,
    DONT,
    UNTIL,
    UNLESS,
    AGAINST,
    
    // literals
    NUMBER,
    NUMBER_GROUP,
    BOOLEAN_VAL,
    BOOLEAN_GROUP,
    IDENTIFIER,
    
    // other glyphs
    COLON,
    AT,
    DOLLAR,
    RIGHT_PAREN,
    LEFT_PAREN,
    RIGHT_BRACKET,
    LEFT_BRACKET,
    RIGHT_BRACE,
    LEFT_BRACE,
    COMMA,
    DOT
}
token_type;
#endif
