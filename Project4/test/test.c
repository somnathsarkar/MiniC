#include <stdio.h>

int max(int a, int b){
    int maxa = a+b;
    return a;
}
int noparams(){
    return 1;
}
void noparamsvoid(){

}
void min(int a, int b){
    a<b;
}
int main(){
    int a;

    a = 1+2;
    int b = 2;
    int c = 3,e = b = 3;
    a++;
    int *d;
    d[+a];
    int ****pnt;
    **pnt;
    ***pnt;
    --****pnt;
    a*b*c;
    a+b*c;
    d[-a] = 1;
    d[a]+=b^c;
    int res;
    noparams();
    min(max(a,b),b);
    noparamsvoid();
    min(a,b);
    int z = 1;
    if (z>5){
        if (z>6){
            z = 6;
        }
        z+1;
    }
    else if(z==0)
        z = z-1;
    else
        z = 5;
}