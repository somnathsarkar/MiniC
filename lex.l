%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
const char * keywords[] = {"int","float","if","else","while"};
int kc = 5;
int match,i;
%}
letter [a-zA-Z]
digit [0-9]
comment "//".*
multicomment "/*"[^/]*"*/"
preprocessor "#".*
ws [\n\t ]+
datatype "int"|"float"
identifier {letter}({digit}|{letter}|[_])*
if_keyword "if"
else_keyword "else"
while_keyword "while"
keyword {if_keyword}|{else_keyword}|{while_keyword}
intliteral {digit}+
floatliteral [+-]?(({digit}+("."{digit}*)?)|("."{digit}+))
literal {intliteral}|{floatliteral}
operator [+\-*/=]
separator [,;{}()]
%Start start_clean start_literal start_identifier start_keyword
%%
{comment} {printf("COMMENT"); BEGIN start_clean;}
{multicomment} {printf("MULTICOMMENT"); BEGIN start_clean;}
{preprocessor} {printf("PREPROCESSOR"); BEGIN start_clean;}
{ws}+ {ECHO; BEGIN start_clean;}
<start_clean>{identifier} {
	match = 0;
	for(i = 0; i<kc; i++){
		if(!strcmp(yytext,keywords[i])){
			match = 1;
			break;
		}
	}
	if(match){
		REJECT;
	}else{
		printf("IDENTIFIER");
		BEGIN start_identifier;
	}
}
<start_clean>{literal} {
	printf("LITERAL");
	BEGIN start_literal;
}
{operator} {printf("OPERATOR"); BEGIN start_clean;}
<start_clean>{datatype} {
	printf("DATATYPE");
	BEGIN start_keyword;
}
<start_clean>{keyword} {
	ECHO;
	BEGIN start_keyword;
}
{separator} {
	ECHO;
	BEGIN start_clean;
}
. {printf("LEXERROR");}
%%
int main(){
	yyin = fopen("test.txt","r");
	yylex();
	return 0;
}
int yywrap(){
	return 1;
}
