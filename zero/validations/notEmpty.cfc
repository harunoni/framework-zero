component extends="valueObject" implements="zero.lib.printable" {

	public valueObject function init(required value){		
		if(trim(arguments.value == "")){
			throw("The value cannot be empty");
		} else {
			variables.value = arguments.value;
		}
		return this;
	}

}