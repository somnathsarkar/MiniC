%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symboltable.h"
extern FILE* yyin;
extern int lineno;
void lexinit();
void printconstanttable();
int was_return;
char datatype[20];
struct symboltable* symstack[100];
char *scstack[100];
int sp = 0;
void init(){
	lexinit();
    scstack[0] = strdup("");
    symstack[0] = createsymboltable();
}
void push(char *scope){
    symstack[++sp] = createsymboltable();
    scstack[sp] = strdup(scope);
}
void pop(){
    apply_scope(symstack[sp],scstack[sp]);
    merge_table(symstack[sp-1],symstack[sp]);
    sp--;
}
void printsymboltable(){
    printf("Symbol Table\n");
    struct node *focus = (symstack[0])->root;
    printf("Identifier Name\tLine\tDatatype\n");
    while(focus){
        printf("%s\t\t%d\t%s\n",focus->id,focus->line,focus->dtype);
        focus = focus->next;
    }
}
void undeclared_identifier(char * x){
	int i;
    for(i = sp; i>=0; i--){
        if(lookup(symstack[i],x))
            return;
    }
    printf("Warning: Undeclared Identifier %s on Line %d\n",x,lineno);
}
%}

%union{
    char * str;
}

%token DATATYPE ID CONSTANT IF WHILE RETURN STRUCTUNION
%token BO BC CBO CBC

%token COMMA EQ PE XE AE OE ME OO AA EQU NE LE GE UNARY_OPERATOR PNT LS RS DE

%right ELSE

%%
S
	: /* empty */
	| STATEMENT S
	;
	
STATEMENT
	: EXP ';'
	| FUNCTIONBLOCK
	| DECLARATION ';'
	;
	
DECLARATION
	: DATATYPE DECLIST
	;
	
DECLIST
	: ID EQ EXP
	| ID
	| DECLIST COMMA ID
	| DECLIST COMMA ID EQ EXP
	;
	
FUNCTIONBLOCK
	: FUNCTIONHEAD CBO S CBC
	| FUNCTIONHEAD ';'
	;

FUNCTIONHEAD
	: DATATYPE ID BO BC
	| DATATYPE ID BO ARGLIST BC
	;
	
ARGLIST
	: DATATYPE ID
	| DATATYPE ID COMMA ARGLIST
	;
	
EXP
	: LOR_EXP
	| LOR_EXP EQ EXP
	| LOR_EXP PE EXP
	| LOR_EXP AE EXP
	| LOR_EXP XE EXP
	| LOR_EXP OE EXP
	| LOR_EXP ME EXP
	| LOR_EXP DE EXP
	;
	
LOR_EXP
	: LAND_EXP
	| LOR_EXP OO LAND_EXP

LAND_EXP
	: BOR_EXP
	| LAND_EXP AA BOR_EXP
	;
	
BOR_EXP
	: BXOR_EXP
	| BOR_EXP '|' BXOR_EXP
	;
	
BXOR_EXP
	: BAND_EXP
	| BXOR_EXP '^' BAND_EXP
	;	

BAND_EXP
	: REL_EXP
	| BAND_EXP '&' REL_EXP
	;
	
REL_EXP
	: CMP_EXP
	| REL_EXP EQU CMP_EXP
	| REL_EXP NE CMP_EXP
	;
	
CMP_EXP
	: SH_EXP
	| CMP_EXP '<' SH_EXP
	| CMP_EXP '>' SH_EXP
	| CMP_EXP LE SH_EXP
	| CMP_EXP GE SH_EXP
	;
	
SH_EXP
	: AS_EXP
	| SH_EXP LS AS_EXP
	| SH_EXP RS AS_EXP
	;

AS_EXP
	: PDM_EXP
	| AS_EXP '+' PDM_EXP
	| AS_EXP '-' PDM_EXP
	;

PDM_EXP
	: PRE_EXP
	| PDM_EXP '*' PRE_EXP
	| PDM_EXP '/' PRE_EXP
	| PDM_EXP '%' PRE_EXP
	;

PRE_EXP
	: POST_EXP
	| UNARY_OPERATOR PRE_EXP
	| '+' PRE_EXP
	| '-' PRE_EXP
	| '!' PRE_EXP
	| '~' PRE_EXP
	| '&' PRE_EXP
	| '*' PRE_EXP
	;

POST_EXP
	: VARLIT
	| POST_EXP UNARY_OPERATOR
	| VARLIT BO ARGLIST BC
	| VARLIT BO BC
	| POST_EXP PNT VARLIT
	| POST_EXP '.' VARLIT
	;
	
VARLIT
	: ID
	| CONSTANT
	| BO VARLIT BC
	;
%%
int main(){
    init();
    yyin = fopen("test.c","r");
    yyparse();
    return 0;
}
int yyerror(const char *s){
    return printf("Syntax Error: Line %d\n",lineno);
}
int yywrap(){
    return 1;
}
