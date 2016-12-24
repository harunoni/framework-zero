component extends="valueObject" {
	public valueObject function init(value){
		if(!isJson(arguments.value)){
			throw("The value passed must valid json but was not");
		}
		return this;
	}
}