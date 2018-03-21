/* test case to check for variable declarations */
int abc(){

}
int abc(){
	
}
int abc;
int main(int a, void vo){
	int a;
	int b; 
	int abc;
	// will give a warning for undeclared identifier c
	a = b + c;

	if(a){
		if(b){
			if(a)
				int x,y;
			int v;
		}
		int u;
	}
	int z;
	// will give a warning for redeclared variable
	int a;
	
}