/* 
	This is a program to test almost all the functionalities provided by the compiler and mainly function calls
*/
int i = 10;
void func( int a){
	i = a;
	while(i!=0)
	{
		printf("%d\n", i);
		i--;
	}
}
		
int main(){
	int i, j = 3;
	float a9;
	a9 = 10.00;
	//Valid function calls
	printf("Hi\n");
	if( i < 2)
		func(7);
	else 
		j = 3;
}
		
