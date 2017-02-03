/**
*/
component extends="directory" {
	public function init(required string mapping, required string path){
		variables.mapping = arguments.mapping;
		super.init(arguments.path);
		return this;
	}

	public function getMappingString(){
		return variables.mapping;
	}
}