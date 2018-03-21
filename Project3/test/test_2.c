// test case to check for errors regarding operator

int main(){
	
	// will give an error since not modifiable
	5++;
	
	float a;
	
	//will give an error since operator is not defined for float operands
	~a;
	
	float b;
	int k;
	a+b = 5; 
	
	// will give an error since logical operator are not defined for float operands
	k = a&b;
	
}
