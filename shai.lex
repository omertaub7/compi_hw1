%{
/* Declaration Section */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER_LEN 128

char buffer[BUFFER_LEN];
void do_error(const char* msg);
void print_token(const char* token, const char* value);

typedef enum _COMMENT1_STATUS {COMMENT1_EOF, COMMENT1_NESTED, COMMENT1_OK} COMMENT1_STATUS;
int comment1_count_lines = 0;
void comment1_start();
void comment1_add_line();
void comment1_end(COMMENT1_STATUS);

void comment2_end();
%}


%option yylineno
%option noyywrap

DEC_DIGIT 				([0-9])
LETTER					([a-zA-Z])
WHITESPACE				([\t\n\r ])
NEWLINE					(([\r\n])|(\r\n))
PRINTABLE				([\x20-\x7E\t\n\r])
PRINTABLE_NO_NEWLINE	([\x20-\x7E\t])
COMMENT1_START			(\/\*)
COMMENT1_END			(\*\/)
COMMENT2_START			(\/\/)

%x COMMENT1
%x COMMENT2

%%
{COMMENT1_START}					comment1_start();
<COMMENT1>{COMMENT1_START}			comment1_end(COMMENT1_NESTED);
<COMMENT1><<EOF>>					comment1_end(COMMENT1_EOF);
<COMMENT1>{COMMENT1_END}			comment1_end(COMMENT1_OK);
<COMMENT1>{NEWLINE}					comment1_add_line();
<COMMENT1>{PRINTABLE_NO_NEWLINE}	;


{COMMENT2_START}					BEGIN(COMMENT2);
<COMMENT2>{NEWLINE}					comment2_end();
<COMMENT2>{PRINTABLE_NO_NEWLINE}	;

<*>.								ECHO;

%%

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
void comment2_end(){
	print_token("COMMENT", "1");
	BEGIN(INITIAL);
}