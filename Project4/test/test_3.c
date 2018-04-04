//test case to check for functions

int max(int a, int b){
	int x, y;
	x = a*b;
	return x;
}

int min(int a,int b);

void main(){
	int k, l ,m ,n;
	k = l*m + n;
	m = max(min(k,l), l);
}
int min(int a, int b){
	return a;
}