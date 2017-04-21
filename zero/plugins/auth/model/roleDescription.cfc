component extends="valueObject" {
	property name="value";
	public valueObject function init(any value){
		if(isSimpleValue(value) and len(value) <=1024){
			variables.value = arguments.value;
		} else {
			throw("The value must be less than 1024 characters");
		}
		return this;
	}
}