/**
*/
component {
	public function init(required string name){
		variables.name = arguments.name;
		return this;
	}

	public string function getBaseName(){
		return listFirst(variables.name,".");
	}

	public string function getExtension(){
		return listLast(variables.name,".");
	}

	public function toString(){
		return variables.name;
	}
}