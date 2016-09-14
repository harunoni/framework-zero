component extends="valueObject" {
	public valueObject function init(string name, any value){
		if(isSimpleValue(value) and len(value) <=255){
			variables.value = arguments.value;
		} else {
			throw("The value passed for #name# must be less than 255 characters");
		}
		return this;
	}
}