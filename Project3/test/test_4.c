// test case to show the implementation of scope

struct s{
	int a,b;
};

int max(int a, int b)
{
	a = b;
}

int main(){
	int a; 
	int b;	
	a = b;
}
