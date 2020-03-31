%{
/* Declaration Section */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STRING_LEN 1024
#define MAX_ASCII 128
void do_error(const char* msg);
void print_token(const char* token, const char* value);

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

DIGIT 					([0-9])
LETTER					([a-zA-Z])
WHITESPACE				([\t\n\r ])
NEWLINE					(([\r\n])|(\r\n))
PRINTABLE				([\x20-\x7E\t\n\r])
PRINTABLE_NO_NEWLINE	([\x20-\x7E\t])



%x STRING

%%

<<<<<<< HEAD
\" 								string_init();
<STRING>\"						string_end();
<STRING>\n						string_error_endline();
<STRING>\\n						string_concat('\n');
<STRING>\\r						string_concat('\r');
<STRING>\\t						string_concat('\t');
<STRING>\\						string_concat('\\');
<STRING>\\"						string_concat('\"');
<STRING>\\u{[0-9a-fA-F]+}       string_num_to_ascii();
<STRING>\\.                     string_error_escape_sequence();
=======
\" 					string_init();
<STRING>\"				string_end();
<STRING>\n				string_error_endline();
<STRING>\\n				string_concat('\n');
<STRING>\\r				string_concat('\r');
<STRING>\\t				string_concat('\t');
<STRING>\\				string_concat('\\');
<STRING>\\\"				string_concat('\"');
<STRING>\\u\{[0-9a-fA-F]+\}		string_num_to_ascii();
<STRING>\\.                             string_error_escape_sequence();
>>>>>>> 9197b4ff17f56f9b870a00354be8e96b10475296
<STRING>[^\\\n\"\r\t]+			string_input(); //TODO - add \u escape to the regex excludes
%%
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
		*string_buf_ptr = *ptr++;
	}
}

void string_error_endline() {
	do_error("Error unclosed string\n");
}

void string_concat(char c) {
	string_index++;
	if (string_index >= STRING_LEN) {
<<<<<<< HEAD
		do_error("Error string too long\n"); //Probably not needed, left for safety
=======
		do_error("Error string too long"); //Probably not needed, left for safety
>>>>>>> 9197b4ff17f56f9b870a00354be8e96b10475296
	}
	*string_buf_ptr++ = c;
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
	if (val >= MAX_ASCII) {
		string_error_escape_sequence();
	}
	 if (string_index >= STRING_LEN) {
                do_error("Error string too long"); //Probably not needed, left for safety
        }
	*string_buf_ptr++ = (char) val;
}

void string_error_escape_sequence() {
	do_error("Error undefined escape sequence");
}
//---------------------------------GENERAL FUNCTIONS-----------------------
void do_error(const char* msg){
	printf("%s\n", msg);
	exit(0);
}

void print_token(const char* token, const char* value) {
        printf("%d %s %s\n", yylineno, token, value);
}

