%{
/* Declerations Section */
#include <stdio.h>
void showToken (cher * name);
%}

%option yylineno
%option noyywrap
/*Declare names of the regular expressions*/
dec_digit ([0-9])
hex_digit ([0-9]|[a-f]|[A-F])
bin_digit ([01])
oct_digit ([0-7])


%%





%%
void showToken (char * name) {
    printf("%d %s %s", &yylineno, name, yytext);
}
