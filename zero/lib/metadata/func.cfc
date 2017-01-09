/**
 * Represents the meta data for a function
*/
component accessors="true" {
	
	public function init(required struct data){
		variables.data = arguments.data;
		return this;
	}

	public boolean function argumentsMatch(required struct args){

		for(var funcArg in variables.data.parameters){

		}

	}

}