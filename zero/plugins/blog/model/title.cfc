/**
*/
component accessors="true" {
	property name="title" setter="false";

	public function init(required any title){

		if(isSimpleValue(arguments.title)){
			initString(arguments.title);
		}		

		if(isObject(arguments.title) and isInstanceOf(arguments.title, "file")){
			initFile(arguments.title);
		}

		return this;
	}	

	public function initFile(required file file){
		var fileName = arguments.file.getFileName();
		var baseName = fileName.getBaseName();
		var out = baseName.replaceNoCase("-", " ", "all");
		variables.title = out;
	}

	public function toString(){
		return variables.title;
	}
}