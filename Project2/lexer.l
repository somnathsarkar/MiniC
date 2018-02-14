%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
extern YYSTYPE yylval;
const char * keywords[] = {"int","float","char","long","short","double","void","if","else","while","struct","for","switch","case","break","union","return"};
int kc = 17;
int yylineno = 1;
%}
letter [a-zA-Z]
digit [0-9]
singlecomment "//".*
multicomment "/*"([^*]|\*[^/])*"*/"
comment {singlecomment}|{multicomment}
danglingcomment "/*"
preprocessor "#".*
ws [\t ]+
newline [\n]
datatype ("int"|"float"|"double"|"long"|"short"|"char"|"void")
identifier {letter}({digit}|{letter}|[_])*
if_keyword "if"
else_keyword "else"
while_keyword "while"
switch_keyword "switch"|"case"|"break"
for_keyword "for"
return_keyword "return"
keyword {if_keyword}|{else_keyword}|{while_keyword}|{switch_keyword}|{return_keyword}
intliteral {digit}+
floatliteral (({digit}+("."{digit}*)?)|("."{digit}+))
stringliteral "\""(\\.|[^\\"])*["]
literal {intliteral}|{floatliteral}|{stringliteral}
binary_operator "+="|"-="|"*="|"/="|"^="|"&="|"|="|"=="|"&&"|"||"|"->"|"!="|"<="|">="|[+\-*/\^&|<>]
unary_operator "++"|"--"
semicolon [;]
comma [,]
%%
{singlecomment} ;
{multicomment} {
    int i = 0;
    for(int i = 0; i < yyleng; i++)
        yylineno+=(yytext[i]=='\n');
}
{preprocessor} ;
{ws} ;
{newline} yylineno++;
{identifier} {
    int match = 0,i = 0;
    for(i = 0; i<kc; i++){
        if(strcmp(keywords[i],yytext)==0){
            match = 1;
            break;
        }
    }
    if(match){
        REJECT;
    }else{
        yylval.str = strdup(yytext);
        return ID;
    }
}
"if" return IF;
"else" return ELSE;
"while" return WHILE;
"return" return RETURN;
"struct"|"union" {yylval.str = strdup(yytext); return STRUCTUNION;}
{unary_operator} {
    return UNARY_OPERATOR;
}
"+=" return PE;
"-=" return ME;
"^=" return XE;
"&=" return AE;
"|=" return OE;
"==" return EQU;
"!=" return NE;
"<=" return LE;
">=" return GE;
"->" return PNT;
[+\-*/\^&|<>] ECHO;
"=" return EQ;
{datatype} {
    yylval.str = strdup(yytext);
    return DATATYPE;
}
{literal} {
    return CONSTANT;
}
";" return *yytext;
"(" return BO;
")" return BC;
"{" return CBO;
"}" return CBC;
{comma} {
    return COMMA;
}
. {
    printf("Lexical Error: Line %d\n",yylineno);
}
%%