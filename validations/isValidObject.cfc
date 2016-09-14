component extends="valueObject" {
	public valueObject function init(required string name, required any value){
		var type = getMetaData(this).name.listLast(".");		
		if(!isValid(type, arguments.value)){
			throw("The value for argument #name# provided #arguments.value# was not a valid #type#");
		} else {
			variables.value = arguments.value;
		}
		return this;
	}
}