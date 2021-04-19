
public class fact {
	
	public static long fact(int n) {
		
		//store some space for the output.
		long output;
		
		// special case for n = 1, where n! is already 1
		if(n == 1) {
			return 1;
		}
		
		// recursion calls itself until n = 1
		output = fact(n-1)* n;
		
		// returning the result
		return output;
	}
	
	
	

	public static void main(String[] args) {
		
		// reseving space for the question Value, eg. q1 = 5!, q2 = 14!
		int qValue;
		// reserving space to store the answer, default R1 and R2 in the assignment
		long answer;
	
		
		// assigning value 5
		qValue = 20;
			
		//calling recursive subroutine on qValue
		answer = fact(qValue);
		System.out.println("Factorial of " + qValue + ": " + answer + "\n");
		
		

	}

}
