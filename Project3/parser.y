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
    merge_table(symstack[sp-1],symstack[sp]);
    sp--;
}
void printcell(char *str){
		int i = 0;
		int space = 0;
		space = 20 - strlen(str);
    	printf("|");
    	for(i = 0; i<3; i++)
    		printf(" ");
    	printf("%s",str);
    	for(i =0 ; i<space; i++)
    		printf(" ");
  }
void printsymboltable(){
	int space = 10;
	int i= 0;
    printf("Symbol Table\n");
    struct node *focus = (symstack[0])->root;
    printf("-------------------------------------------------------------------------------------------------\n");
    printf("|   Identifier Name     |   Line\t\t|   Datatype\t        |   Scope\t        |\n");
    printf("-------------------------------------------------------------------------------------------------\n");
    while(focus){ 
    	printcell(focus->id);
    	char str[30];
    	sprintf(str,"%d",focus->line);
    	printcell(str);
    	printcell(focus->dtype);
    	printcell(focus->scope);
    	printf("|");
    	printf("\n");
    	printf("-------------------------------------------------------------------------------------------------\n");
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
	struct exp_type{
		int mutable;
		char *dtype;
	};
}

%token DATATYPE ID CONSTANT IF WHILE RETURN STRUCTUNION
%token BO BC CBO CBC

%token COMMA EQ PE XE AE OE ME OO AA EQU NE LE GE UNARY_OPERATOR PNT LS RS DE

%right "then" ELSE

%%
S
	: /* empty */
	| STATEMENT S
	;
	
STATEMENT
	: EXP ';'
	| FUNCTIONBLOCK
	| DECLARATION ';'
	| COMPOUND_STATEMENT
	| IFHEAD STATEMENT %prec "then"
	| IFHEAD STATEMENT ELSE STATEMENT
	| WHILEHEAD STATEMENT
	;	

COMPOUND_STATEMENT
	: '{' S '}'
	;

IFHEAD
	: IF BO EXP BC
	;

WHILEHEAD
	: WHILE BO EXP BC
	;
	
DECLARATION
	: DATATYPE DECLIST
	| STRUCTUNION '{' DECLARATION_LIST '}'
	;

DECLARATION_LIST
	: DECLARATION
	| DECLARATION DECLARATION_LIST
	;
	
DECLIST
	: DECID EQ EXP
	| DECID
	| DECLIST COMMA DECID
	| DECLIST COMMA DECID EQ EXP
	;

DECID
	: ID
	| '*' DECID
	;
	
FUNCTIONBLOCK
	: FUNCTIONHEAD COMPOUND_STATEMENT
	| FUNCTIONHEAD ';'
	;

FUNCTIONHEAD
	: DATATYPE DECID BO BC
	| DATATYPE DECID BO ARGLIST BC
	;
	
ARGLIST
	: DATATYPE DECID
	| DATATYPE DECID COMMA ARGLIST
	;

EXPLIST
	: EXP
	| EXP COMMA EXPLIST
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
	| VARLIT BO EXPLIST BC
	| VARLIT BO BC
	| POST_EXP PNT VARLIT
	| POST_EXP '.' VARLIT
	| POST_EXP '[' POST_EXP ']'
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