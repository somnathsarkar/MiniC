%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symboltable.h"
extern FILE* yyin;
extern int yylineno;
int was_return;
char datatype[20];
struct symboltable* symstack[100];
char *scstack[100];
int sp = 0;
void init(){
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
    printf("\nIdentifier Name\tDatatype\tLine\n");
    while(focus){
        printf("%s\t\t%s\t\t%d\n",focus->id,focus->dtype,focus->line);
        focus = focus->next;
    }
}
void undeclared_identifier(char * x){
    for(int i = sp; i>=0; i--){
        if(lookup(symstack[i],x))
            return;
    }
    printf("Warning: Undeclared Identifier %s on Line %d\n",x,yylineno);
}
%}

%union{
    char * str;
}

%token DATATYPE ID CONSTANT IF WHILE RETURN STRUCTUNION
%token BO BC CBO CBC

%left COMMA
%left UNARY_OPERATOR PNT
%left '*' '/'
%left '+' '-'
%left '<' '>' LE GE
%left EQU NE
%left '&'
%left '^'
%left '|'
%right ELSE
%right EQ

%%
S
    : S_REC {printsymboltable();}
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
    ;
DECLARATIONLIST
    : ID {add_identifier(symstack[sp],$<str>1,datatype);}
    | ID COMMA DECLARATIONLIST {add_identifier(symstack[sp],$<str>1,datatype);}
    | ID EQ RVALUE {add_identifier(symstack[sp],$<str>1,datatype);}
    | ID EQ RVALUE COMMA DECLARATIONLIST {add_identifier(symstack[sp],$<str>1,datatype);}
    ;
COMPOUNDDECLARATION
    : STRUCTUNION ID {add_identifier(symstack[sp],$<str>2,$<str>1); push($<str>2);} CBO ASSIGNMENTLIST CBC {pop();}
    ;
ASSIGNMENTLIST
    : /* empty */
    | DATATYPE {strcpy(datatype,$<str>1);} IDCHAIN ';' ASSIGNMENTLIST
    ;
IDCHAIN
    : ID {add_identifier(symstack[sp],$<str>1,datatype);}
    | ID COMMA IDCHAIN {add_identifier(symstack[sp],$<str>1,datatype);}
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
    : VALIDSTATEMENT
    | FUNCTIONHEAD {if (strcmp($<str>1,"void")){was_return = 0;} $<str>$ = strdup($<str>1);} CBO MULTISTATEMENT CBC {if(strcmp($<str>1,"void")&&!was_return)printf("Warning: Return value expected for non-void function on Line %d\n",yylineno);was_return=0;pop();}
    ;
FUNCTIONID
    : DATATYPE ID BO {$<str>$ = strdup($<str>1); strcpy(datatype,$<str>1); strcat(datatype,"()"); add_identifier(symstack[sp],$<str>2,datatype); push($<str>2); }
    ;
FUNCTIONHEAD
    : FUNCTIONID ARGLIST BC {}
    | FUNCTIONID BC
    ;
ARGLIST
    : DATATYPE ID {add_identifier(symstack[sp],$<str>2,$<str>1);}
    | DATATYPE ID COMMA ARGLIST {add_identifier(symstack[sp],$<str>2,$<str>1);}
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
    | VARLIT BIN_OP EXPRESSION {}
    | VARLIT COMMA EXPRESSION {}
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
    | BINARY_OPERATOR
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
    return printf("Syntax Error: Line %d\n",yylineno);
}
int yywrap(){
    return 1;
}