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
	//Valid function calls
	printf("Hello World\n");
	if( i < 2)
		functionCall(abc_9);
	else 
		j = 3;
	//Invalid function calls
	functionCall;
	functionCall[];
}
		
