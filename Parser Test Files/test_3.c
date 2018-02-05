//Testcase for function syntax error
#include<stdio.h>

void max(int a,int b);

int min(int a,int b);

int main(){

    //Valid Test  cases

    int a=7;
    int b=8;
    int c;

    max(a,b);

    c = min(a,b);
    //Invalid Test cases

    max(a);       //Insuffucient parameters

    min(a, b);    //Return value not assigned

    float c = 0.0;

    max(a,c);    //function doesnt expect float parameters

    max(1,2,3);  //Function Call error
     
    return 0;
}