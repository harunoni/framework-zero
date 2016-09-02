component extends="valueObject" {
	public function init(name, value){
		if(!isJson(arguments.value)){
			throw("The value passed for #name# must valid json but was not");
		}
	}
}