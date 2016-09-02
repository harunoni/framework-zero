component extends="valueObject" {
	function init(string name, any value){		
		if(isNumeric(value) and (value == 0 or value == "0")){
			variables.value = arguments.value;
		} else {
			throw("The value passed for #name# must be zero #value#");
		}
	}
}