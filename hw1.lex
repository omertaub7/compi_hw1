%{
/* Declerations Section */

/* TODO: check for
 * What happens when the numbers do not fit integer valus?(long?)
 * Integrate string, comments
 * FIX ID not allowed number inside
*/
#include <stdio.h>

// defenitions to use the digits
typedef enum _BASE_TYPE {BASE_BIN = 0, BASE_OCT, BASE_DEC, BASE_HEX} BASE_TYPE;
const int BASE_VALUE[] = {2, 8, 10, 16};
const char* const BASE_NAME[] = {"BIN", "OCT", "DEC", "HEX"}; 

// shows a simple token
void showToken (char* name);
// deal with an integer in one of the methods
void showInt (BASE_TYPE);

void illegalChar (); //TODO: Check how to pass only the char and not all the string

%}

%option yylineno
%option noyywrap


DEC_DIGIT 			([0-9])
HEX_DIGIT 			([0-9a-fA-F])
BIN_DIGIT 			([01])
OCT_DIGIT 			([0-7])
LETTER 				([a-zA-Z])
WHITESPACE 			([\t\n\r ])

DEC_REAL_NO_EXP		((({DEC_DIGIT}+)\.({DEC_DIGIT}*))|(({DEC_DIGIT}*)\.({DEC_DIGIT}+)))

%%
Int|UInt|Double|Float|Bool|String|Character		showToken("TYPE");
var								showToken("VAR");
let								showToken("LET");
func							showToken("FUNC");
import							showToken("IMPORT");
nil								showToken("NIL");
while							showToken("WHILE");
if								showToken("IF");
else							showToken("ELSE");
return							showToken("RETURN");
true							showToken("TRUE");
false							showToken("FALSE");

;								showToken("SC");
,								showToken("COMMA");
\(								showToken("LPAREN");
\)								showToken("RPAREN");
\{								showToken("LBRACE");
\}								showToken("RBRACE");
\[								showToken("LBRACKET");
\]								showToken("RBRACKET");
=								showToken("ASSIGN");
(==|!=|<|<=|>=)					showToken("REALOP");
((\|\|)|(\&\&))					showToken("LOGOP");
(\+|-|\*|\/|\%)					showToken("BINOP");
(->)							showToken("ARROW");
:								showToken("COLON");

0b{BIN_DIGIT}+        			showInt(BASE_BIN);
0o{OCT_DIGIT}+        			showInt(BASE_OCT);
{DEC_DIGIT}+          			showInt(BASE_DEC);
0x{HEX_DIGIT}+        			showInt(BASE_HEX);

{DEC_REAL_NO_EXP}								showToken("DEC_REAL");
{DEC_REAL_NO_EXP}[Ee][+-]({DEC_DIGIT}+)			showToken("DEC_REAL");

0x({HEX_DIGIT}+)[pP][+-]({DEC_DIGIT}+)   	    showToken("HEX_FP");

({LETTER}+)(({LETTER}|{DEC_DIGIT})+)			showToken("ID");
_(({LETTER}|{DEC_DIGIT})+)						showToken("ID");


{WHITESPACE}					;

.								illegalChar();
%%
void showToken (char* name) 
{
    printf("%d %s %s\n", yylineno, name, yytext);
}

void showInt(BASE_TYPE base_type) 
{
	char* num_start = yytext;
	if (base_type != BASE_DEC){
		num_start = yytext + 2;
	}
	int value = strtol(num_start, NULL, BASE_VALUE[base_type]);
	printf("%d %s%s %d\n", yylineno, BASE_NAME[base_type], "_INT", value);
}

void illegalChar() 
{
    printf("Error %s \n", yytext);
    exit(0);
}
