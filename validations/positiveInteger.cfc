component extends="valueObject" {
	function init(string name, any value){
		if(isNumeric(value) and value <= 0){
			throw("The value passed for #name# must be a positive number");
		} else {
			variables.value = arguments.value;
		}
	}
}