component extends="valueObject" {
	public valueObject function init(any value){		
		if(isNumeric(value) and (value == 0 or value == "0")){
			variables.value = arguments.value;
		} else {
			throw("The value must be zero");
		}
		return this;
	}
}