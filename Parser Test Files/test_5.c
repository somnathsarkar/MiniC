// Valid test case
#include <stdio.h>

int max(int a, int b){
    if(a>b)
        return a;
    return b;
}

int main(){
    int a = 10,b;
    b = a+5;
    int c = max(a,b);
    printf("%d\n",c);
    while(a<=b){
        int d = 5;
        while(d>0){
            d--;
            a+=2;
        }
    }
    c = max(a,b);
    printf("%d",c);
    return 0;
}
