/**
*/
component {
	public function init(required file file, required path basePath){
		var out = arguments.file.toString().replaceNoCase("#arguments.basePath.toString()#", "", "all");
		variables.canonicalUrl = out.replaceNoCase(".cfm", "");
		return this;
	}

	public function toString(){
		return variables.canonicalUrl;
	}
}