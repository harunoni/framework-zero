component extends="valueObject" {
	function init(string name, any value){
		if(isSimpleValue(value) and len(value) <= 65535){
			variables.value = arguments.value;
		} else {
			throw("The value passed for #name# must be less than 65,535 characters");
		}

	}
}