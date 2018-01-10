/*
	This is a program to test the compiler for handling loops, datatype, comments and basic arithmetic operations
*/

int main(){
	int a;
	a = 1;
	int b = 5;
	
	// Correct test case for If else loop
	if( a == 1)                 
		b = 2;
	else if ( b == 5)
		b = 4;
	else
		b = 5;
		
	// Incorrect test case for if else loop
	else if( b == 5)
		int c = 0; 	
	
	//Valid while loop statement 
	while(b!=0){
		b--;
	}
	
	//Invalid while loop
	while ;
	
	
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

