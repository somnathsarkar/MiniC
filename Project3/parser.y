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
    	printcell(focus->id);
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
}

%token DATATYPE ID CONSTANT IF WHILE RETURN STRUCTUNION
%token BO BC CBO CBC

%left COMMA
%right EQ PE XE AE OE ME
%left OO
%left AA
%left '|'
%left '^'
%left '&'
%left EQU NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/'
%left UNARY_OPERATOR PNT
%right ELSE

%%
S
    : S_REC {printsymboltable();printconstanttable();}
    ;
S_REC
    : /* empty */
    | VALIDSTATEMENT S_REC
    | FUNCTIONBLOCK S_REC
    ;
VALIDSTATEMENT
    : STATEMENT ';'
    | IFHEAD VALIDSTATEMENT ELSEBLOCK
    | IFHEAD CBO MULTISTATEMENT CBC ELSEBLOCK
    | WHILEHEAD VALIDSTATEMENT
    | WHILEHEAD CBO MULTISTATEMENT CBC
    ;
MULTISTATEMENT
    : /* empty */
    | VALIDSTATEMENT MULTISTATEMENT
    ;
STATEMENT
    : /* empty */
    | ASSIGNMENT
    | COMPOUNDDECLARATION
    | COMPOUNDDECLARATION IDCHAIN
    | EXPRESSION
    | RETURN EXPRESSION {was_return = 1;}
    ;
ASSIGNMENT
    : DATATYPE {strcpy(datatype,$<str>1);} DECLARATIONLIST
    | STRUCTUNION ID {undeclared_identifier($<str>2); strcpy(datatype,$<str>1);} IDCHAIN
    ;
DECLARATIONLIST
    : ID {add_identifier(symstack[sp],$<str>1,datatype,scstack[sp]);}
    | ID COMMA DECLARATIONLIST {add_identifier(symstack[sp],$<str>1,datatype,scstack[sp]);}
    | ID EQ RVALUE {add_identifier(symstack[sp],$<str>1,datatype,scstack[sp]);}
    | ID EQ RVALUE COMMA DECLARATIONLIST {add_identifier(symstack[sp],$<str>1,datatype,scstack[sp]);}
    ;
COMPOUNDDECLARATION
    : STRUCTUNION ID {add_identifier(symstack[sp],$<str>2,$<str>1,scstack[sp]); push($<str>2); $<str>$ = strdup($<str>1);} CBO ASSIGNMENTLIST CBC {strcpy(datatype,$<str>1);pop();}
    ;
ASSIGNMENTLIST
    : /* empty */
    | DATATYPE {strcpy(datatype,$<str>1);} IDCHAIN ';' ASSIGNMENTLIST
    ;
IDCHAIN
    : ID {add_identifier(symstack[sp],$<str>1,datatype,scstack[sp]);}
    | ID COMMA IDCHAIN {add_identifier(symstack[sp],$<str>1,datatype,scstack[sp]);}
    ;
IFHEAD
    : IF BO EXPRESSION BC
    ;
ELSEBLOCK
    : /* empty */
    | ELSE VALIDSTATEMENT
    | ELSE CBO MULTISTATEMENT CBC
    ;
WHILEHEAD
    : WHILE BO EXPRESSION BC
    ;
FUNCTIONBLOCK
    : FUNCTIONHEAD {if (strcmp($<str>1,"void")){was_return = 0;} $<str>$ = strdup($<str>1);} CBO MULTISTATEMENT CBC {if(strcmp($<str>1,"void")&&!was_return)printf("Warning: Return value expected for non-void function on Line %d\n",lineno);was_return=0;pop();}
    ;
FUNCTIONID
    : DATATYPE ID BO {$<str>$ = strdup($<str>1); strcpy(datatype,$<str>1); strcat(datatype,"()"); add_identifier(symstack[sp],$<str>2,datatype,scstack[sp]); push($<str>2); }
    ;
FUNCTIONHEAD
    : FUNCTIONID ARGLIST BC {}
    | FUNCTIONID BC
    ;
ARGLIST
    : DATATYPE ID {add_identifier(symstack[sp],$<str>2,$<str>1,scstack[sp]);}
    | DATATYPE ID COMMA ARGLIST {add_identifier(symstack[sp],$<str>2,$<str>1,scstack[sp]);}
    ;
RVALUE
    : VARLIT
    | FUNCTIONCALL
    | VARLIT BIN_OP RVALUE
    | BO RVALUE BC
    ;
EXPRESSION 
    : VARLIT
    | FUNCTIONCALL
    | VARLIT BIN_OP EXPRESSION
    | VARLIT COMMA EXPRESSION
    | BO EXPRESSION BC
    | UN_OP EXPRESSION
    | EXPRESSION UN_OP
    ;
FUNCTIONCALL
    : ID BO EXPRESSION BC {undeclared_identifier($<str>1);}
    | ID BO BC {undeclared_identifier($<str>1);}
    ;
BIN_OP
    : EQ
    | PE
    | ME
    | XE
    | AE
    | OE
    | OO
    | AA
    | '+'
    | '-'
    | '&'
    | '*'
    | '/'
    | '^'
    | '<'
    | LE
    | GE
    | '>'
    | EQU
    | NE
    | PNT
    ;
UN_OP
    : UNARY_OPERATOR
    ;
VARLIT
    : ID {undeclared_identifier($<str>1);}
    | CONSTANT
    ;
%%
int main(){
    init();
    yyin = fopen("../Parser Test Files/test_5.c","r");
    yyparse();
    return 0;
}
int yyerror(const char *s){
    return printf("Syntax Error: Line %d\n",lineno);
}
int yywrap(){
    return 1;
}
