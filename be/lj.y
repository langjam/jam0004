%{
#include <stdio.h>
#include <string.h>
#include "lib.h"

int yylex(void);
void yyerror(const char * msg);
extern FILE * yyin;

%}

%define api.value.type { const char * }

%token  WORD NAME FUNCTION_NAME ASSIGNMENT PRINT
%token  CALL
%token  CURRY_DOTS
%token  ALGEBRAIC_INTEROGATION
%token  SEMI_COLON
%token  RBRACE LBRACE

%start program
%%
program : {
    FILE *f = fopen("clap.c", "w+");
    fprintf(f, "#include <stdio.h>\n"
                "#include <stdlib.h>\n"
               "#include <string.h>\n\n");
    fclose(f);
} cmmands { dump_main(); } ;

cmmands : cmmands command SEMI_COLON
        | command SEMI_COLON ;

command : fu_decl
        | fu_call ;

fu_decl : FUNCTION_NAME {
            push_function($1);
        } LBRACE inner_fu_decl RBRACE {
            dump_function();
        } ;

inner_fu_decl : inner_fu_decl fu_call SEMI_COLON
              | fu_call SEMI_COLON ;


fu_call : WORD { push_function_call($1); } arguments rest
        | PRINT { push_print(); } arguments
        | CALL arguments ;

rest    : %empty
        | CURRY_DOTS {
            fill_curryfication();
        }
        | ALGEBRAIC_INTEROGATION {
            fill_algebraic();
        };

arguments : arguments argument
          | argument ;

argument  : WORD ASSIGNMENT NAME {
                push_parameter($3);
                push_arg_name($1, $3);
            }
          | WORD ASSIGNMENT WORD {
                push_arg_const($1, $3);
            }
          | WORD ASSIGNMENT CURRY_DOTS {
                push_arg_curry($1);
            }
          | WORD ASSIGNMENT ALGEBRAIC_INTEROGATION {
                push_arg_alge($1);
            } ;
          | NAME {
                push_parameter($1);
                push_arg_print($1);
            }
          | WORD {
                push_arg_print_const($1);
            } ;

%%
void yyerror(const char * msg)
{
    printf("error: %s, %s\n", msg, yylval);
}

int main(int argc, char ** argv)
{
    if(argc>1)
        yyin = fopen(argv[1],"r");
    if(yyparse())
        exit(14);
    return 0;
}