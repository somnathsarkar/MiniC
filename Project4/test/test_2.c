//test case for checking nested if else statements

#include<stdio.h>


void main(){
	int a, b, c, d, x, y, z;
	b += a -= d = 5;
	if(a==b)
	{
		if(b==c)
		{
			x = y*z;
		}
		else
		{
			y = x*z;
		}
	}
	else
	{
		z = y*x;
	}
}

