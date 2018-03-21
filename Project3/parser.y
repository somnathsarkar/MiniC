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
int last_func = -1;
char *last_fname;
char datatype[20];
struct symboltable* symstack[100];
const char *allow_types[] = {"char","short","int","long","float","double","void"};
int allow_mask[3][7] = {{1,1,1,1,0,0,0},{1,1,1,1,1,1,0},{0,0,0,0,0,0,1}};
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
	merge_table(symstack[sp-1],symstack[sp],0);
    sp--;
}
char * get_scope(){
	char *ret;
	if(sp==0)
		ret = strdup("");
	else{
		ret = strdup(scstack[1]);
		for(int i = 2; i<=sp; i++){
			char *newret = (char *)malloc(strlen(ret)+1+strlen(scstack[i])+1);
			strcpy(newret,ret);
			strcat(newret,".");
			strcat(newret,scstack[i]);
			free(ret);
			ret = newret;
		}
	}
	return ret;
}
void printcell(char *str){
		if(str==NULL)
			str = strdup("");
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

char *indirect(char *str){
	char *newstr = (char *)malloc(strlen(str)+2);
	strcpy(newstr,str);
	strcat(newstr,"*");
	return newstr;
}

char *deref(char *str){
	if(!strlen(str)||str[strlen(str)-1]!='*')
		return str;
	char *newstr = (char *)malloc(strlen(str));
	strncpy(newstr,str,strlen(str)-1);
	return newstr;
}

void check_pnt(char *str){
	if(!strlen(str)||str[strlen(str)-1]!='*')
		printf("Semantic Error: Expression requires pointer type, %s received on Line %d\n",str,lineno);
}

char *check_func(char *fun, char* params){
	for(int i = sp; i>=0; i--){
		struct node *lu = lookup(symstack[i],fun);
		if(lu!=NULL){
			if(lu->dtype[strlen(lu->dtype)-1]!=')')
				printf("Semantic Error: %s is called as a function, is of type %s on Line %d\n",lu->id,lu->dtype,lineno);
			else{
				int pnt = 0;
				while(lu->dtype[pnt]!='(')
					pnt++;
				if(strcmp(((lu->dtype)+pnt),params))
					printf("Semantic Error: For function %s got parameters %s, expected %s on Line %d\n",lu->id,params,(lu->dtype)+pnt,lineno);
				char *ret = (char *)malloc(pnt+1);
				strncpy(ret,lu->dtype,pnt);
				return ret;
			}
		}
	}
	return strdup("void");
}

void check_mod(struct exp_type exp);
struct exp_type undeclared_identifier(char * x);
int check_exp(struct exp_type exp, int am, char *op);
char *iconv(struct exp_type e1, struct exp_type e2);
%}

%code requires {
	struct exp_type{
		int mod;
		char *dtype;
	}exp;
}

%union{
    char * str;
	struct exp_type exp;
	struct symboltable *sym;
}

%token DATATYPE ID CONSTANT IF WHILE RETURN STRUCTUNION
%token BO BC

%token COMMA EQ PE XE AE OE ME OO AA EQU NE LE GE UNARY_OPERATOR PNT LS RS DE

%right "then" ELSE

%%
START_SYMBOL
	: S
	;
S
	: /* empty */
	| STATEMENT S
	;
	
STATEMENT
	: EXP ';'
	| FUNCTIONBLOCK
	| DECLARATION ';' {merge_table(symstack[sp],$<sym>1,1);}
	| COMPOUND_STATEMENT
	| IFHEAD STATEMENT %prec "then" {pop();}
	| IFHEAD STATEMENT ELSE {pop(); push("else");} STATEMENT {pop();}
	| WHILEHEAD STATEMENT {pop();}
	| RETURN EXP ';' {was_return = 1;}
	;	

COMPOUND_STATEMENT
	: '{' S '}'
	;

IFHEAD
	: IF BO EXP BC {push("if");  check_exp($<exp>3,0,"if test");}
	;

WHILEHEAD
	: WHILE BO EXP BC {push("while"); check_exp($<exp>3,0,"while test");}
	;
	
DECLARATION
	: DATATYPE DECLIST {assign_datatype($<sym>2,$<str>1); $<sym>$ = $<sym>2;}
	| STRUCTUNION ID '{' DECLARATION_LIST '}' {
		push($<str>2);
		merge_table(symstack[sp],$<sym>4,1);
		pop();
		$<sym>$ = createsymboltable();
		add_identifier($<sym>$,$<str>2,$<str>1);
	}
	| STRUCTUNION ID '{' DECLARATION_LIST '}' DECLIST {
		push($<str>2);
		merge_table(symstack[sp],$<sym>4,1);
		pop();
		char *su_dtype = (char *)malloc(strlen($<str>1)+1+strlen($<str>2)+1);
		strcpy(su_dtype,$<str>1);
		strcat(su_dtype," ");
		strcat(su_dtype,$<str>2);
		assign_datatype($<sym>6,su_dtype);
		free(su_dtype);
		$<sym>$ = createsymboltable();
		add_identifier($<sym>$,$<str>2,$<str>1);
		merge_table($<sym>$,$<sym>6,1);
	}
	| STRUCTUNION ID DECLIST
	;

DECLARATION_LIST
	: DECLARATION ';' {$<sym>$ = $<sym>1;}
	| DECLARATION DECLARATION_LIST {merge_table($<sym>1,$<sym>2,1); $<sym>$ = $<sym>1;}
	;
	
DECLIST
	: DECID EQ EXP
	| DECID
	| DECLIST COMMA DECID {merge_table($<sym>1,$<sym>3,1);}
	| DECLIST COMMA DECID EQ EXP {merge_table($<sym>1,$<sym>3,1);}
	;

DECID
	: ID {$<sym>$ = createsymboltable(); add_identifier($<sym>$,$<str>1,"?");}
	| '*' DECID {apply_indirection($<sym>2);$<sym>$=$<sym>2;}
	;
	
FUNCTIONBLOCK
	: FUNCTIONHEAD COMPOUND_STATEMENT {
		pop();
		if(!strcmp(datatype,"void")){
			if(was_return)
				printf("Semantic Warning Found return in function of type void on Line %d\n",lineno);
		}else if(!was_return)
			printf("Semantic Warning No return found in function of type %s on Line %d\n",datatype,lineno);
	}
	| FUNCTIONHEAD ';' {pop();}
	;

FUNCTIONHEAD
	: DATATYPE DECID BO BC {
		char* functype = (char *)malloc(strlen($<str>1)+3);
		strcpy(functype,$<str>1);
		strcpy(datatype,$<str>1);
		strcat(functype,"()");
		assign_datatype($<sym>2,functype);
		free(functype);
		char* funcname = strdup($<sym>2->root->id);
		last_func = lineno;
		last_fname = strdup(funcname);
		merge_table(symstack[sp],$<sym>2,1);
		push(funcname);
		free(funcname);
		was_return = 0;
	}
	| DATATYPE DECID BO ARGLIST BC {
		char* funcargs = dstring($<sym>4);
		char* functype = (char *)malloc(strlen($<str>1)+strlen(funcargs)+1);
		strcpy(functype,$<str>1);
		strcpy(datatype,$<str>1);
		strcat(functype,funcargs);
		assign_datatype($<sym>2,functype);
		free(functype);
		char* funcname = strdup($<sym>2->root->id);
		last_func = lineno;
		last_fname = strdup(funcname);
		merge_table(symstack[sp],$<sym>2,1);
		push(funcname);
		free(funcname);
		merge_table(symstack[sp],$<sym>4,1);
		was_return = 0;
	}
	;
	
ARGLIST
	: DATATYPE DECID {assign_datatype($<sym>2,$<str>1); $<sym>$ = $<sym>2;}
	| DATATYPE DECID COMMA ARGLIST {assign_datatype($<sym>2,$<str>1); merge_table($<sym>2,$<sym>4,1); $<sym>$ = $<sym>2;}
	;

EXPLIST
	: EXP {$<str>$ = strdup($<exp>1.dtype);}
	| EXP COMMA EXPLIST {
		$<str>$ = (char *)malloc(strlen($<exp>1.dtype)+1+strlen($<str>3)+1);
		strcpy($<str>$,$<exp>1.dtype);
		strcat($<str>$,",");
		strcat($<str>$,$<str>3);
	}
	;
	
EXP
	: LOR_EXP
	| LOR_EXP EQ EXP {check_mod($<exp>1); check_exp($<exp>1,1,"="); check_exp($<exp>3,1,"="); $<exp>$.dtype = strdup($<exp>1.dtype); $<exp>$.mod = 0;}
	| LOR_EXP PE EXP {check_mod($<exp>1); check_exp($<exp>1,1,"+="); check_exp($<exp>3,1,"+="); $<exp>$.dtype = strdup($<exp>1.dtype); $<exp>$.mod = 0;}
	| LOR_EXP AE EXP {check_mod($<exp>1); check_exp($<exp>1,0,"&="); check_exp($<exp>3,0,"&="); $<exp>$.dtype = strdup($<exp>1.dtype); $<exp>$.mod = 0;}
	| LOR_EXP XE EXP {check_mod($<exp>1); check_exp($<exp>1,0,"^="); check_exp($<exp>3,0,"^="); $<exp>$.dtype = strdup($<exp>1.dtype); $<exp>$.mod = 0;}
	| LOR_EXP OE EXP {check_mod($<exp>1); check_exp($<exp>1,0,"|="); check_exp($<exp>3,0,"|="); $<exp>$.dtype = strdup($<exp>1.dtype); $<exp>$.mod = 0;}
	| LOR_EXP ME EXP {check_mod($<exp>1); check_exp($<exp>1,1,"-="); check_exp($<exp>3,1,"-="); $<exp>$.dtype = strdup($<exp>1.dtype); $<exp>$.mod = 0;}
	| LOR_EXP DE EXP {check_mod($<exp>1); check_exp($<exp>1,1,"/="); check_exp($<exp>3,1,"/="); $<exp>$.dtype = strdup($<exp>1.dtype); $<exp>$.mod = 0;}
	;
	
LOR_EXP
	: LAND_EXP
	| LOR_EXP OO LAND_EXP {check_exp($<exp>1,1,"||"); check_exp($<exp>3,1,"||"); $<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}

LAND_EXP
	: BOR_EXP
	| LAND_EXP AA BOR_EXP {check_exp($<exp>1,1,"&&"); check_exp($<exp>3,1,"&&"); $<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}
	;
	
BOR_EXP
	: BXOR_EXP
	| BOR_EXP '|' BXOR_EXP {check_exp($<exp>1,0,"|"); check_exp($<exp>3,0,"|"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	;
	
BXOR_EXP
	: BAND_EXP
	| BXOR_EXP '^' BAND_EXP {check_exp($<exp>1,0,"^"); check_exp($<exp>3,0,"^"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	;	

BAND_EXP
	: REL_EXP
	| BAND_EXP '&' REL_EXP {check_exp($<exp>1,0,"&"); check_exp($<exp>3,0,"&"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	;
	
REL_EXP
	: CMP_EXP
	| REL_EXP EQU CMP_EXP {check_exp($<exp>1,1,"=="); check_exp($<exp>3,1,"=="); $<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}
	| REL_EXP NE CMP_EXP {check_exp($<exp>1,1,"!="); check_exp($<exp>3,1,"!="); $<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}
	;
	
CMP_EXP
	: SH_EXP
	| CMP_EXP '<' SH_EXP {check_exp($<exp>1,1,"<"); check_exp($<exp>3,1,"<"); $<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}
	| CMP_EXP '>' SH_EXP {check_exp($<exp>1,1,">"); check_exp($<exp>3,1,">"); $<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}
	| CMP_EXP LE SH_EXP {check_exp($<exp>1,1,"<="); check_exp($<exp>3,1,"<="); $<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}
	| CMP_EXP GE SH_EXP {check_exp($<exp>1,1,">="); check_exp($<exp>3,1,">="); $<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}
	;
	
SH_EXP
	: AS_EXP
	| SH_EXP LS AS_EXP {check_exp($<exp>1,0,"<<"); check_exp($<exp>3,0,"<<"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	| SH_EXP RS AS_EXP {check_exp($<exp>1,0,">>"); check_exp($<exp>3,0,">>"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	;

AS_EXP
	: PDM_EXP
	| AS_EXP '+' PDM_EXP {check_exp($<exp>1,1,"+"); check_exp($<exp>3,1,"+"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	| AS_EXP '-' PDM_EXP {check_exp($<exp>1,1,"-"); check_exp($<exp>3,1,"-"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	;

PDM_EXP
	: PRE_EXP
	| PDM_EXP '*' PRE_EXP {check_exp($<exp>1,1,"*"); check_exp($<exp>3,1,"*"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	| PDM_EXP '/' PRE_EXP {check_exp($<exp>1,1,"/"); check_exp($<exp>3,1,"/"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	| PDM_EXP '%' PRE_EXP {check_exp($<exp>1,0,"%"); check_exp($<exp>3,0,"%"); $<exp>$.dtype = iconv($<exp>1,$<exp>3); $<exp>$.mod = 0;}
	;

PRE_EXP
	: POST_EXP
	| UNARY_OPERATOR PRE_EXP {check_mod($<exp>2); $<exp>$.dtype = strdup($<exp>2.dtype); $<exp>$.mod = 0; }
	| '+' PRE_EXP {$<exp>$.dtype = strdup($<exp>2.dtype); $<exp>$.mod = 0;}
	| '-' PRE_EXP {$<exp>$.dtype = strdup($<exp>2.dtype); $<exp>$.mod = 0;}
	| '!' PRE_EXP {$<exp>$.dtype = strdup("int"); $<exp>$.mod = 0;}
	| '~' PRE_EXP {check_exp($<exp>2,0,"~"); $<exp>$.mod = 0;}
	| '&' PRE_EXP {check_exp($<exp>2,1,"&"); check_mod($<exp>2); $<exp>$.dtype = indirect($<exp>2.dtype); $<exp>$.mod = 0;}
	| '*' PRE_EXP {check_pnt($<exp>2.dtype); check_mod($<exp>2); $<exp>$.dtype = deref($<exp>2.dtype); $<exp>$.mod = 1;}
	;

POST_EXP
	: ID {$<exp>$ = undeclared_identifier($<str>1);}
	| CONSTANT
	| POST_EXP UNARY_OPERATOR {check_mod($<exp>1); $<exp>$.mod = 0;}
	| ID BO EXPLIST BC {
		char *params = (char *)malloc(strlen($<str>3)+3);
		strcpy(params,"(");
		strcat(params,$<str>3);
		strcat(params,")");
		char *ftype = check_func($<str>1,params);
		undeclared_identifier($<str>1);
		$<exp>$.dtype = ftype;
		$<exp>$.mod = 0;
	}
	| ID BO BC {undeclared_identifier($<str>1); char *ftype = check_func($<str>1,strdup("()")); $<exp>$.dtype = ftype; $<exp>$.mod = 0;}
	| POST_EXP PNT ID {check_pnt($<exp>1.dtype); $<exp>$.mod = 1;}
	| POST_EXP '.' ID {$<exp>$.mod = 1;}
	| POST_EXP '[' POST_EXP ']' {check_pnt($<exp>1.dtype); check_exp($<exp>3,0,"[]"); $<exp>$.dtype = deref($<exp>1.dtype); $<exp>$.mod = 1;}
	;
%%
void check_mod(struct exp_type exp){
	if(exp.mod&&strcmp(exp.dtype,"void"))
		return;
	printf("Semantic Error: Unmodifiable lvalue on Line %d\n",lineno);
}
struct exp_type undeclared_identifier(char * x){
	int i;
	char *scope = get_scope();
	int n = strlen(scope);
    for(i = sp; i>=0; i--){
		struct node *lu = lookup(symstack[i],x);
		int m = 0;
		if(lu)
			m = strlen(lu->scope);
        if(lu!=NULL&&m<=n&&!strncmp(lu->scope,scope,m)){
			struct exp_type ret;
			ret.dtype = strdup(lu->dtype);
			ret.mod = 1;
            return ret;
		}
    }
    printf("Semantic Warning: Undeclared Identifier %s on Line %d\n",x,lineno);
	struct exp_type ret;
	ret.dtype = strdup("void");
	ret.mod = 1;
    return ret;
}
int check_exp(struct exp_type exp, int am, char *op){
	for(int i = 0; i<7; i++){
		if(!strcmp(exp.dtype,allow_types[i])){
			if(allow_mask[am][i])
				return 1;
			else{
				printf("Semantic Error: ");
				if(strlen(exp.dtype)<=3)
					printf("Operator ");
				printf("%s not defined on type %s on Line %d\n",op,exp.dtype,lineno);
				return 0;
			}
		}
	}
	printf("Semantic Error: Operator %s not defined on type %s on Line %d\n",op,exp.dtype,lineno);
	return 0;
}
char *iconv(struct exp_type e1, struct exp_type e2){
	int t1 = -1,t2 = -1;
	for(int i = 0; i<7; i++)
		if(!strcmp(e1.dtype,allow_types[i]))
		 t1 = i;
	for(int i = 0; i<7; i++)
		if(!strcmp(e2.dtype,allow_types[i]))
		 t2 = i;
	int t = (t1<t2)?(t2):(t1);
	return strdup(allow_types[t]);
}
int main(){
    init();
    yyin = fopen("test/test_4.c","r");
    yyparse();
	if(last_func == -1)
		printf("Semantic Warning: No functions found\n");
	else if(strcmp(last_fname,"main"))
		printf("Semantic Warning: Main was not the last function declared, last function was %s on Line %d\n",last_fname,last_func);
	printsymboltable();
    return 0;
}
int yyerror(const char *s){
    return printf("Syntax Error: Line %d\n",lineno);
}
int yywrap(){
    return 1;
}