// test case to check error regarding referencing of a pointer and some array errors

void main(){
	
	int a;
	
	// will give an error since a is of type int an * expects a type pointer
	*a;
	
	int *b;
	
	//will not give an error since b is defined as int*
	int c = -*b;
	
	int **aa;
	
	//will give an error since a is defined only as a[][]
	aa[2][2][2];


	//will give an error	
	ab[1.1];

	return 1;
	
}

