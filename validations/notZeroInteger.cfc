component extends="valueObject" {
	public valueObject function init(any value){		
		if(isNumeric(value) and !value == 0){
			variables.value = arguments.value;
		} else {
			throw("The value must greater than 0 or less than 0");
		}
		return this;
	}
}