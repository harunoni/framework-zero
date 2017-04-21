component extends="valueObject" {
	public valueObject function init(required any value){
		var type = getMetaData(this).name.listLast(".");
		if(!isValid("email", arguments.value)){
			throw("The value #arguments.value# was not a valid email address");
		} else {
			variables.value = arguments.value;
		}
		return this;
	}
}