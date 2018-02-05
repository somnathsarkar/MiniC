//Testcase for loop statements and if else statements

#include<stdio.h>

int main(){


    int a=10;
    int b=15;

    // Valid if else statements
    if(a>b){
        printf("hi 1");
    }
    else{
        printf(" hi 2")
    }

    // Valid while loop
    while(a>0)
        a--;

    // Valid while loop
    while(b>0)
    {
        printf("Hi 3")
        b--;
    }
    
    // Invalid if statement: No condition
    if(){
        printf("Error");
    }
    
    a = 5;
    
    // Invalid else statement: No matching if
    else{
        
    }
     
    return 0;
}
