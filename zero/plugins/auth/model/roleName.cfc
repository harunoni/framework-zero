component extends="valueObject" {
	property name="value";
	public valueObject function init(any value){
		if(isSimpleValue(value) and len(value) <=255){

			if(trim(arguments.value) == ""){
				throw("The role name cannot be empty");
			}

			variables.value = lcase(trim(arguments.value));
		} else {
			throw("The value must be less than 255 characters");
		}
		return this;
	}

}