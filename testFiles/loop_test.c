/*
	This is a program to test the compiler for handling loops, datatype, comments and basic arithmetic operations
*/
int a,b=5,c;
int main(){
	a = 1;
	c = a;
	// Correct test case for If else loop
	if( a == 1)                 
		b = 2;
	else if ( b == 5)
		b = 4;
	else
		b = 5;
	
	//Valid while loop statement 
	while(b!=0){
		b--;
	}	
	
	// TestCase for checking the correct working of nested loops 
	while(a!=0)
	{
		printf("%d", a);
		a--;
		while(b!=0)
		{	
			printf("%d", b);
			b--;
			while(c!=0)
			{
				printf("%d", c);
				c--;
			}
		}
	}
}

