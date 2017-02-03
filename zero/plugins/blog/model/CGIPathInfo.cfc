/**
*/
component {
	public function init(required string path){
		variables.path = arguments.path;
		return this;
	}

	public includePath function toIncludePath(required directory basePath, required mapping mapping){
		variables.file = variables.path & ".cfm";
		var fullPath = basePath.appendFile(variables.file);
		var IncludePath = new IncludePath(fullPath, arguments.mapping);
		return IncludePath;
	}

}