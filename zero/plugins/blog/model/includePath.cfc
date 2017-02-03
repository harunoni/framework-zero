/**
 * Transforms a file path to a valid path that can be used with cfinclude
*/
component accessors="true"{

	property name="path";

	public function init(required file file, required mapping mapping){		
		var out = "";
		//Remove the file system path and replace with the mapping path
		out = mapping.getMappingString() & file.toString().replaceNoCase(mapping.toString(),"");
		variables.path = out;
		return this;
	}

	public function toString(){
		return variables.path;
	}
}