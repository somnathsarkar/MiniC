//Testcase for function syntax error
#include<stdio.h>

// Valid function declaration
int min(int a,int b){
    if(a<b)
        return a;
    return b;
}

// Invalid function declaration: no parameters
int max{
    return 1;
}

int main(){

    //Valid Test  cases
    int a=7;
    int b=8;
    int c;
    
    // Valid function call
    c = min(a,b);
    
    // Invalid function call: No closing parenthesis
    c = min(a,b;
     
    return 0;
}
