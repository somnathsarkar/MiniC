%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
struct hash_node{
	char *str;
	int id;
	struct hash_node* next;
};
const char * keywords[] = {"int","float","char","long","short","double","void","if","else","while","struct","for","switch","case","break","union","return"};
const char * errormsg[] = {"Could not identify token","Dangling Comment","Dangling String Literal"};
const char * literals[] = {"Integer\t","Floating Point","String\t"};
const int MOD = 104729,PRIME = 1009;
struct hash_node* hash_map[2][104729];
char scope_prefix[100],ctmp[100];
char *identifiers[100],*dtypes[100],*constants[100];
int ctypes[100],idline[100],conline[100];
char datatype[100];
int idstack[100],sp,newdef = 0;
int lines = 1;
int kc = 17,idc = 0,opensmall = 0,imp = 0,conc = 0;
int lastdef = 0;
int match,i;
int errors[100],errorlines[100],ec = 0;
int constant_type(char* str){
	if(strstr(str,"\""))
		return 2;
	if(strstr(str,"."))
		return 1;
	return 0;
}
int compute_hash(char* str){
	int len = strlen(str),i,ans = 0;
	for(i = len-1; i>=0; i--){
		ans=(ans*PRIME)%MOD;
		ans+=str[i];
	}
	return ans;
}
int insert_hash(struct hash_node** hash_map, char *s,int lookup, int is_func){
	char *str = s;
	if(newdef||lookup){
		scope_prefix[0] = '\0';
		for(int i = 0; i<sp; i++){
			strcat(scope_prefix,identifiers[idstack[i]]);
			strcat(scope_prefix,".");
		}
		strcat(scope_prefix,s);
		str = scope_prefix;
	}
	int len = strlen(str);
	int hashval = compute_hash(str);
	struct hash_node** p = &hash_map[hashval];
	while(*p){
		if(!strcmp((*p)->str,str))
			return 0-((*p)->id);
		(*p)++;
	}
	if(lookup)
		return insert_hash(hash_map,s,0,is_func);
	(*p) = (struct hash_node*)malloc(sizeof(struct hash_node));
	(*p)->str = (char *)malloc(len+1);
	strcpy((*p)->str,str);
	(*p)->id = idc;
	identifiers[idc] = (*p)->str;
	dtypes[idc] = (char *)malloc(strlen(datatype)+1);
	idline[idc] = lines;
	strcpy(dtypes[idc],datatype);
	if(is_func)
		strcat(dtypes[idc],"()");
	idc++;
	if(!opensmall)
		imp=idc;
	(*p)->next = NULL;
	return (*p)->id;
}
int insert_constant_hash(struct hash_node** hash_map, char *s){
	char *str = s;
	int len = strlen(str);
	int hashval = compute_hash(str);
	struct hash_node** p = &hash_map[hashval];
	while(*p){
		if(!strcmp((*p)->str,str))
			return 0-((*p)->id);
		(*p)++;
	}
	(*p) = (struct hash_node*)malloc(sizeof(struct hash_node));
	(*p)->str = (char *)malloc(len+1);
	strcpy((*p)->str,str);
	(*p)->id = conc;
	constants[conc] = (*p)->str;
	ctypes[conc] = constant_type(str);
	conline[conc] = lines;
	conc++;
	(*p)->next = NULL;
	return (*p)->id;
}
void init(){
	int i,j;
	for(j = 0; j<2; j++)
		for(int i = 0; i<MOD; i++)
			hash_map[j][i] = NULL;
	scope_prefix[0] = '\0';
	sp = 0;
	datatype[0] = '\0';
}
void push(int x){
	idstack[sp++] = x;
}
int pop(){
	return idstack[--sp];
}
int isempty(){
	return (sp==0);
}
%}
letter [a-zA-Z]
digit [0-9]
comment "//".*
multicomment "/*"([^*]|\*[^/])*"*/"
danglingcomment "/*"
preprocessor "#".*
ws [\t ]+
newline [\n]
datatype ("int"|"float"|"double"|"long"|"short"|"char"|"struct"|"union"|"void")\**
identifier {letter}({digit}|{letter}|[_])*
if_keyword "if"
else_keyword "else"
while_keyword "while"
switch_keyword "switch"|"case"|"break"
for_keyword "for"
return_keyword "return"
keyword {if_keyword}|{else_keyword}|{while_keyword}|{switch_keyword}|{return_keyword}
intliteral {digit}+
floatliteral [+-]?(({digit}+("."{digit}*)?)|("."{digit}+))
stringliteral "\""(\\.|[^\\"])*["]
literal {intliteral}|{floatliteral}|{stringliteral}
operator "+="|"++"|"--"|"-="|"*="|"/="|"^="|"&="|"|="|"=="|"&&"|"||"|"->"|"!="|"<="|">="|[+\-*/=\^&|<>]
separator [;]
startscope [{(]
endscope [)}]
comma [,]
%Start start_clean start_literal start_identifier start_keyword
%%
{comment} {printf("COMMENT"); BEGIN start_clean;}
{multicomment} {
	printf("MULTICOMMENT");
	for(int i = 0; i<yyleng; i++){
		if(yytext[i]=='\n')
			lines++;
	}
	BEGIN start_clean;
}
{danglingcomment} {errorlines[ec] = lines; errors[ec++] = 1; BEGIN start_clean;}
{preprocessor} {printf("PREPROCESSOR"); BEGIN start_clean;}
{ws} {ECHO; BEGIN start_clean;}
{newline} {ECHO; lines++; BEGIN start_clean;};
<start_clean>{identifier} {
	int is_func = 0,i,rev=0;
	ctmp[rev++] = input();
	while((ctmp[rev-1]==' '||ctmp[rev-1]=='\t'||ctmp[rev-1]=='\n')){
		ctmp[rev++] = input();
	}
	if(ctmp[rev-1]=='(')
		is_func = 1;
	char *yycopy = (char *)malloc(yyleng+1);
	strcpy(yycopy,yytext);
	for(i=rev-1;i>=0; i--)
		unput(ctmp[i]);
	match = 0;
	for(i = 0; i<kc; i++){
		if(!strcmp(yycopy,keywords[i])){
			match = 1;
			break;
		}
	}
	if(match){
		free(yycopy);
		REJECT;
	}else{
		lastdef = insert_hash(hash_map[0],yycopy,1,is_func);
		printf("(identifier,%d)",abs(lastdef));
		newdef = 0;
		free(yycopy);
		BEGIN start_identifier;
	}
}
<start_clean>{literal} {
	printf("(constant,%d)",abs(insert_constant_hash(hash_map[1],yytext)));
	BEGIN start_literal;
}
{operator} {printf("(operator,%s)",yytext); BEGIN start_clean;}
<start_clean>{datatype} {
	printf("(datatype,%s)",yytext);
	BEGIN start_keyword;
	strcpy(datatype,yytext);
	newdef = 1;
}
<start_clean>{keyword} {
	printf("(keyword,%s)",yytext);
	BEGIN start_keyword;
}
{startscope} {
	printf("(separator,%s)",yytext);
	BEGIN start_clean;
	push(imp-1);
	if(yytext[0]=='(')
		opensmall++;
}
{endscope} {
	printf("(separator,%s)",yytext);
	BEGIN start_clean;
	pop();
	if(yytext[0]==')')
		opensmall--;
}
{separator} {
	printf("(separator,%s)",yytext);
	BEGIN start_clean;
	datatype[0] = 0;
	newdef = 0;
}
{comma} {
	printf("(separator,,)");
	BEGIN start_clean;
	if(datatype[0])
		newdef = 1;
}
. {
	if(yytext[0]=='"')
		errors[ec] = 2;
	else
		errors[ec] = 0;
	errorlines[ec++] = lines;
}
%%
void printerrors(){
	for(int i = 0; i<ec; i++)
		printf("Lexical Error on Line: %d, %s\n",errorlines[i],errormsg[errors[i]]);
}
void printidentifiers(){
	printf("\t\tIdentifier No.\tIdentifier Name\tIdentifier Type\tLine\n");
	for(int i = 0; i<idc; i++)
		printf("\t\t%d\t\t%s\t\t%s\t\t%d\n",i,identifiers[i],dtypes[i],idline[i]);
}
void printconstants(){
	printf("\t\tConstant No.\tConstant Value\tConstant Type\t\tLine\n");
	for(int i = 0; i<conc; i++)
		printf("\t\t%d\t\t%s\t\t%s\t\t%d\n",i,constants[i],literals[ctypes[i]],conline[i]);
}
int main(){
	init();
	yyin = fopen("test.txt","r");
	yylex();
	printf("\n");
	if(ec){
		printf("One or more errors were found:\n");
			printerrors();
	}
	if(!ec){
		printidentifiers();
		printf("\n");
		printconstants();
	}
	return 0;
}
int yywrap(){
	return 1;
}