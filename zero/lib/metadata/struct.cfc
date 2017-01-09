/**
*/
component {
	public function init(required struct data){
		variables.data = arguments.data
		return this;
	}

	public function onMissingMethod(missingMethodName){

		var accessor = left(missingMethodName, 3);

		if(accessor == "get"){
			var name = right(missingMethodName, len(missingMethodName) -3);
			if(fileExists("#name#.cfc")){
				return createObject(name).init(variables.data[name]);
			} else {
				if(isStruct(variables.data[name])){
					return new struct(variables.data[name]);					
				}
			}
		}

		if(accessor == "set"){
			throw("Struct is immutable, cannot call a setter");
		}
	}

	public function toStruct(){
		return variables.data;
	}

	public function toString(){
		return serialize(variables.data);
	}

	public function toJson(){
		return serializeJson(variables.data);
	}

	public array function keyArray(){
		return structKeyArray(variables.data)
	}
}