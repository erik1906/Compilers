class Program{

	int main(){
		int i;
		int j;
		i = 0;
		j = 1;
		if((i<j) && (j<2 )){
			j = j * 2;
			callout ("printf", "i:%d ,j: %d\n", i, j); 
		}
		else {
			j=j+4;
			callout ("printf", "i:%d ,j:%d\n", i, j); 
		}
	return 0;
	}	
}

