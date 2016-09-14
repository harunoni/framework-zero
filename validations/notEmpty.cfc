component extends="valueObject" {

	public valueObject function init(required name, required value){		
		if(trim(arguments.value == "")){
			throw("The value for #name# cannot be empty");
		} else {
			variables.value = arguments.value;
		}
		return this;
	}

}