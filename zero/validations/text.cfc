component extends="valueObject" {
	public valueObject function init(any value){
		if(isSimpleValue(value) and len(value) <= 65535){
			variables.value = arguments.value;
		} else {
			throw("The value must be less than 65,535 characters");
		}
		return this;
	}
}