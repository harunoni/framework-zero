component extends="valueObject" {

	public function init(required argumentName, required value){
		if(trim(arguments.value == "")){
			throw("The value for #argumentName# cannot be empty");
		} else {
			variables.value = arguments.value;
		}
		return this;
	}

}