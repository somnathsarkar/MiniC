%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
extern YYSTYPE yylval;
const char * keywords[] = {"int","float","char","long","short","double","void","if","else","while","struct","for","switch","case","break","union","return"};
int kc = 17;
int lineno = 1;
const int MOD = 104729,PRIME = 1009;
struct hash_node{
	char *value,*dtype;
	int line;
	struct hash_node *next;
}*hash_map[104729];
int compute_hash(const char *str){
	int ans = 0;
	int len = strlen(str);
	int i;
	for(i = 0; i<len; i++){
		ans*=PRIME;
		ans%=MOD;
		ans+=str[i];
		ans%=MOD;
	}
	return ans;
}
int hash_lookup(const char *str){
	int hash_value = compute_hash(str);
	struct hash_node *focus = hash_map[hash_value];
	while(focus){
		if(!strcmp(focus->value,str))
			return 1;
		focus = focus->next;
	}
	return 0;
}
void insert_hash(const char *str){
	if (hash_lookup(str))
		return;
	int hash_value = compute_hash(str);
	if(hash_map[hash_value]==NULL){
		hash_map[hash_value] = (struct hash_node *)malloc(sizeof(struct hash_node));
		hash_map[hash_value]->value = strdup(str);
		if(strstr(str,"\""))
			hash_map[hash_value]->dtype = strdup("String");
		else if(strstr(str,"."))
			hash_map[hash_value]->dtype = strdup("Floating-Point");
		else
			hash_map[hash_value]->dtype = strdup("Integer");
		hash_map[hash_value]->line = lineno;
		hash_map[hash_value]->next = NULL;
	}else{
		struct hash_node *focus = hash_map[hash_value];
		while(focus->next)
			focus = focus->next;
		focus->next = (struct hash_node *)malloc(sizeof(struct hash_node));
		focus->next->value = strdup(str);
		if(strstr(str,"\""))
			focus->next->dtype = strdup("String");
		else if(strstr(str,"."))
			focus->next->dtype = strdup("Floating-Point");
		else
			focus->next->dtype = strdup("Integer");
		focus->next->line = lineno;
		focus->next->next = NULL;
	}
}
void printconstanttable(){
	printf("Constant Table\nValue\tLine\tType\n");
	int i;
	for(i=0; i<MOD; i++){
		struct hash_node *focus = hash_map[i];
		while(focus){
			printf("%s\t%d\t%s\n",focus->value,focus->line,focus->dtype);
			focus = focus->next;
		}
	}
}
void lexinit(){
	int i;
	for(i = 0; i<MOD; i++)
		hash_map[i] = NULL; 
}
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
    for(i = 0; i < yyleng; i++)
        lineno+=(yytext[i]=='\n');
}
{preprocessor} ;
{ws} ;
{newline} lineno++;
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
"&&" return AA;
"||" return OO;
[+\-*/\^&|<>] return *yytext;
"=" return EQ;
{datatype} {
    yylval.str = strdup(yytext);
    return DATATYPE;
}
{literal} {
	insert_hash(yytext);
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
"\r" ;
. {
    printf("Lexical Error: Line %d\n",lineno);
}
%%
