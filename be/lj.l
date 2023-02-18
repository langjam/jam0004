%{

void yyerror(const char * msg);
#include "lj.h"

%}

%option noyywrap

name $[a-zA-Z_][a-zA-Z0-9_]*
word [a-zA-Z0-9_]+
function_name {word}"()"
%%


[ \t\r] { /* ignore whitespace */ };
\n { yylval = strdup(yytext);  };

{function_name} {
    yylval = strdup(yytext);
    return FUNCTION_NAME;
}

"print" {
    return PRINT;
}

"call" {
    return CALL;
}

{word} {
    yylval = strdup(yytext);
    return WORD;
}

{name} {
    yylval = strdup(yytext);
    return NAME;
}

"..." {
    return CURRY_DOTS;
}

"?" {
    return ALGEBRAIC_INTEROGATION;
}

"=" {
    return ASSIGNMENT;
}

"{" {
    return LBRACE;
}

"}" {
    return RBRACE;
}

";" {
    return SEMI_COLON;
}

%%