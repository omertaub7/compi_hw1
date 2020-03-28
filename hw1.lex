%{
/* Declerations Section */
#include <stdio.h>
void showToken (char * name);
void showNum (char * Base(;
void illegalChar (); //TODO: Check how to pass only the char and not all the string
%}

%option yylineno

dec_digit ([0-9])
hex_digit ([0-9a-fA-F])
bin_digit ([01])
oct_digit ([0-7])
letter ([a-zA-Z])
whitespace ([\t\n ])
%%
0b(bin_digit)+        					showNum("BIN");
0o(oct_digit)+        					showNum("OCT");
(dec_digit)+          					showNum("DEC");
0x(hex_digit)+        					showNum("HEX");
(dec_digit)*\.(dec_digit)+				showToken("DEC_REAL");
0x(hex_digit)+[pP][+-](dec_digit)+      		showToken("HEX_FP");
/* TODO: STRING Lex */                  		showToekn("STRING"); //should be bottom, just before the unknown match
Int|UInt|Double|Floar|Bool|String|Character		showToken("TYPE");
_?(letter)+						showToken("ID"); //show be down, after all keyworkds
var							showToken("VAR");
let							showToken("LET");
func							showToken("FUNC");
import							showToken("IMPORT");
nil							showToken("NIL");
while							showToken("WHILE");
if							showToken("IF");
else							showToken("ELSE");
return							showToken("RETURN");
\u{3B}							showToken("SC");
\u{}							showToken("COMMA");
\u{}							showToken("LPAREN");
\u{}							showToken("RPAREN");
\u{}							showToken("LBRACE");
\u{}							showToken("RBRACE");
\u{}							showToken("LBRACKET");
\u{}							showToken("RBRACKET");
\u{}							showToken("ASSIGN");
/* TODO: REALOP*/					showToken("REALOP");
/* TODO: LOGOP*/					showToken("LOGOP");
/* TODO: BINOP*/					showToken("BINOP");
true							showToken("TRUE");
false							showToken("FALSE");
/* TODO: Arrow and colon and comments */

whitespace						;
.							illegalChar();
%%
void showToken (char * name) {
    printf("%d %s %s", yylineno, name, yytext);
}

void showNum (char * Base) {
    printf("%d %s_INT ", yylineno, Base);
    switch (Base) {
	case HEX:
	printf("%d \n", strtol(yytext+2, NULL, 16));
	break;
	case BIN:
	printf("%d \n", strtol(yytext+2, NULL, 2);
	break;
	case OCT:
	printf("%d \n", strtol(yytext+2, NULL, 8);
	break;
	case DEC:
	printf("%d \n", strtol(yytext, NULL, 10);
	break;
	default:
	break;
}

void illegalChar () {
    printf("Error %s \n", yytext);
    exit(0);
}
