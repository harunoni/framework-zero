component extends="valueObject" {
	public valueObject function init(required any value){
		var type = getMetaData(this).name.listLast(".");		
		if(!isValid(type, arguments.value)){
			throw("The value #arguments.value# was not a valid type: #type#");
		} else {
			variables.value = arguments.value;
		}
		return this;
	}
}