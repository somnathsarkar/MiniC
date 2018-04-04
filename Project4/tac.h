#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

char* mcat(int count, ...);
char* sapp(char* dest, char* src);
char* tacagn(char* var);
char* slastterm(char* tac);
char* lastterm(char* tac);
char* poplast(char* tac);
char* arrop(char* tac1, char* tac2);
char* postfix(char* tac, char* op);
char* prefix(char* tac, char* op);
char* unary(char* tac, char* op);
char* binop(char* tac1, char* tac2, char* op);
char* assign(char* tac1, char* tac2, char* op);