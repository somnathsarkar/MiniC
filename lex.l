letter [a-zA-Z]
digit [0-9]
comment "//".*
multicomment "/*"[^/]*"*/"
ws [\n\t ]+
datatype "int"|"float"
variable {letter}({digit}|{letter}|[_])*
intliteral [+-]?{digit}+
floatliteral [+-]?(({digit}+("."{digit}*)?)|("."{digit}+))
varlit {variable}|{intliteral}|{floatliteral}
addop {varlit}{ws}?"+"{ws}?{varlit}
subop {varlit}{ws}?"-"{ws}?{varlit}
mulop {varlit}{ws}?"*"{ws}?{varlit}
divop {varlit}{ws}?"/"{ws}?{varlit}
op {addop}|{subop}|{mulop}|{divop}
value {varlit}|{op}
assignment {ws}?"="{ws}?{value}
poss_assignment {variable}{assignment}?
declaration {datatype}{ws}{poss_assignment}(","{ws}?{poss_assignment})*{ws}?";"
assignment_statement {variable}{assignment}";"
function_header ({datatype}|"void"){ws}{variable}{ws}?"("({datatype}{ws}{variable}{ws}?(","{ws}?{datatype}{ws}{variable}{ws}?))?{ws}?")"
%%
{comment} printf("COMMENT");
{multicomment} printf("MULTICOMMENT");
{declaration} printf("DECLARATION");
{assignment_statement} printf("ASSIGNMENT");
{function_header} printf("FUNCTION");
%%
int main(){
	yyin = fopen("test.txt","r");
	yylex();
}

int yywrap(){
	return 1;
}
