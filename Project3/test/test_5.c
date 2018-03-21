// test case to check errors regarding functions


int maxval(int a, int b)
	return a;
}

int main()
	
	int a;
	
	//will give an error since maxval expects an (int, int) as parameters but it is getting (float, int)
	a = maxval(1.0, 1);
		
	int b ;
	
	//will give an error saying that maxval expects an (int, int) as parameters but it is getting (int, int, int)
	b = maxval(1,1,1);
	
	// error saying no return statement
}
	
