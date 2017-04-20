component extends="valueObject" {
	public valueObject function init(any value){
		if(isSimpleValue(value) and len(value) <=255){
			variables.value = arguments.value;
		} else {
			throw("The value must be less than 255 characters");
		}
		return this;
	}
}