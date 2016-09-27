component extends="valueObject" {
	public valueObject function init(any value){
		if(isNumeric(value) and value >= 0){
			throw("The value must be a negative number");
		} else {
			variables.value = arguments.value;
		}
		return this;
	}
}