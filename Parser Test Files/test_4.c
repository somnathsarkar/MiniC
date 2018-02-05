//Testcase for loop statements and if else statements

#include<stdio.h>

void max(int a,int b);

int main(){
    //Valid Test cases


    int a=10;
    int b=15;

    if(a>b){
        printf("hi 1");
    }
    else{
        printf(" hi 2")
    }

    while(a>0)
        a--;

    while(b>0)
    {
        printf("Hi 3")
        b--;
    }
    //Invalid Test Cases

    if(){
        printf("Error");
    }

    //Else without a previuos if

    else{

    }
     
    return 0;
}