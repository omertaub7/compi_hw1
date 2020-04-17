%{
/* Declerations Section */
/* TODO: check for
 * What happens when the numbers do not fit integer valus?(long?)
 * Integrate string, comments
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
// defenitions to use the digits
typedef enum _BASE_TYPE {BASE_BIN = 0, BASE_OCT, BASE_DEC, BASE_HEX} BASE_TYPE;
const int BASE_VALUE[] = {2, 8, 10, 16};
const char* const BASE_NAME[] = {"BIN", "OCT", "DEC", "HEX"}; 

// shows a simple token
void showToken (char* name);
// deal with an integer in one of the methods
void showInt (BASE_TYPE);
bool printable (int val);
void illegalChar (); //TODO: Check how to pass only the char and not all the string

//---------------------COMMENT handeling code---------------------------------
#define BUFFER_LEN 128
char buffer[BUFFER_LEN];
void do_error(const char* msg);

void print_token(const char* token, const char* value);

typedef enum _COMMENT1_STATUS {COMMENT1_EOF, COMMENT1_NESTED, COMMENT1_OK} COMMENT1_STATUS;
int comment1_count_lines = 0;
void comment1_start();
void comment1_add_line();
void comment1_end(COMMENT1_STATUS);

void comment2_end(bool new_line);


//------------------STRING------------------
#define STRING_LEN 1024
#define MAX_ASCII 128
char string_buffer[STRING_LEN];
char *string_buf_ptr;
int string_index;

void string_init ();
void string_end();
void string_error_endline();
void string_concat(char c);
void string_num_to_ascii();
void string_error_escape_sequence();
void string_input();
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

NEWLINE					(([\r\n])|(\r\n))
PRINTABLE				([\x20-\x7E\t\n\r])
PRINTABLE_NO_NEWLINE	([\x20-\x7E\t])
COMMENT1_START			(\/\*)
COMMENT1_END			(\*\/)
COMMENT2_START			(\/\/)

%x COMMENT1
%x COMMENT2
%x STRING

%%

\" 								string_init();
<STRING>\"						string_end();
<STRING>\n						string_error_endline();
<STRING>\\n						string_concat('\n');
<STRING>\\r						string_concat('\r');
<STRING>\\t						string_concat('\t');
<STRING>\\\\					string_concat('\\');
<STRING>\\\"					string_concat('\"');
<STRING>\\u\{[0-9a-fA-F]+\}		string_num_to_ascii();
<STRING>\\[^\\]                 string_error_escape_sequence();
<STRING>{PRINTABLE_NO_NEWLINE} 	string_input(); 

{COMMENT1_START}					comment1_start();
<COMMENT1>{COMMENT1_START}			comment1_end(COMMENT1_NESTED);
<COMMENT1><<EOF>>					comment1_end(COMMENT1_EOF);
<COMMENT1>{COMMENT1_END}			comment1_end(COMMENT1_OK);
<COMMENT1>{NEWLINE}					comment1_add_line();
<COMMENT1>{PRINTABLE_NO_NEWLINE}	;


{COMMENT2_START}					BEGIN(COMMENT2);
<COMMENT2>{NEWLINE}					comment2_end(true);
<COMMENT2><<EOF>>                   comment2_end(false);
<COMMENT2>{PRINTABLE_NO_NEWLINE}	;

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
(==|!=|<|<=|>=|>)				showToken("RELOP");
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

({LETTER}+)(({LETTER}|{DEC_DIGIT})*)			showToken("ID");
_(({LETTER}|{DEC_DIGIT})+)						showToken("ID");


{WHITESPACE}					;

<*>.							illegalChar();
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
    printf("Error %s\n", yytext);
    exit(0);
}

//-------COMMENT HEANDELING CODE------------------------
//---------------------------------GENERAL FUNCTIONS-----------------------
void do_error(const char* msg){
	printf("%s\n", msg);
	exit(0);
}

void print_token(const char* token, const char* value){
	printf("%d %s %s\n", yylineno, token, value);
}

//---------------------------------COMMENT1 FUNCTIONS-----------------------
void comment1_start(){
	comment1_count_lines = 1;
	BEGIN(COMMENT1);
}
void comment1_add_line(){
	comment1_count_lines++;
}
void comment1_end(COMMENT1_STATUS status){
	switch(status){
		case COMMENT1_EOF: 		do_error("Error unclosed comment"); 
			break;
		case COMMENT1_NESTED: 	do_error("Warning nested comment");
			break;
		case COMMENT1_OK:		sprintf(buffer, "%d", comment1_count_lines);
								print_token("COMMENT", buffer);
								BEGIN(INITIAL);
			break;
	}
}

//---------------------------------COMMENT2 FUNCTIONS-----------------------
void comment2_end(bool new_line){
	if (new_line){
		printf("%d %s %d\n", yylineno - 1, "COMMENT", 1);
	} else {
		printf("%d %s %d\n", yylineno, "COMMENT", 1);
	}
	
	BEGIN(INITIAL);
}
//---------------------------------STRING  FUNCTIONS-----------------------"
void string_init () {
	BEGIN(STRING);
	string_index = 0;
	string_buf_ptr = string_buffer;
}

void string_end () {
	BEGIN(INITIAL);
	string_buf_ptr = NULL;
	print_token("STRING", string_buffer);		
	memset(string_buffer, '\0', sizeof(string_buffer));
}

void string_input() {
	char * ptr = yytext;
	while (*ptr) {
		*string_buf_ptr = *ptr;
		string_buf_ptr++; ptr++;
	}
}

void string_error_endline() {
	do_error("Error unclosed string");
}

void string_concat(char c) {
	string_index++;
	if (string_index >= STRING_LEN) {
		do_error("Error string too long"); //Probably not needed, left for safety
	}
	*string_buf_ptr++ = c;
}

bool printable (int val) {
	return (val == 0x9 || val == 0xA || val == 0xD || (val >= 0x20 && val <= 0x7E));
}

void string_num_to_ascii () {
	char* ascii_ptr = yytext;
	while (*ascii_ptr != '{') {
		ascii_ptr++;
	}
	char* start_ptr = ++ascii_ptr;
	while (*ascii_ptr != '}') {
	/* According to the rule, this string represents a valid hex number */
		ascii_ptr++;
	}
	*ascii_ptr = '\0';
	int val = (int) strtol(start_ptr, NULL, 16);
	if (!printable(val)) {
		string_error_escape_sequence();
	}
	 if (string_index >= STRING_LEN) {
                do_error("Error string too long"); //Probably not needed, left for safety
        }
	*string_buf_ptr++ = (char) val;
}

void string_error_escape_sequence() {
	printf("Error undefined escape sequence %s\n", yytext + 1);
	exit(0); 
}
