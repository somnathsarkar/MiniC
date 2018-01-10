/* 
	This is a program to test almost all the functionalities provided by the compiler and mainly function calls
*/

void functionCall( float a){
	int  i = 1;
	while(i!=0)
	{
		printf("%d", a);
		i--;
	}
}
		
int main(){
	int i, j = 3;
	float abc_9;
	abc_9 = 10.00;
	printf("Hello World\n");
	if( i < 2)
		functionCall(abc_9);
	else 
		j = 3;
	// Invalid number of parameters to call the function functionCall in the if condition
	if( j > 1)
		functionCall();					
	else
		functionCall(abc_9);
}
		
