/**
 * Represents working with a directory
*/
component implements="path" {
	public function init(required string directory){
		variables.directory = arguments.directory;		
		if(right(variables.directory, 1) == "/"){
			variables.directory = left(variables.directory, len(variables.directory) - 1);
		}
		variables.directory = cleanDoubleSlash(variables.directory);
		return this;
	}

	public directory function append(path){
		var newPath = "#variables.directory#/#arguments.path#";
		return new directory(newPath);
	}

	public file function appendFile(path){
		var newPath = "#variables.directory#/#arguments.path#";
		newPath = cleanDoubleSlash(newPath);
		return new file(newPath);
	}


	public boolean function exists(){
		if(directoryExists(variables.directory)) {
			return true;
		} else {
			return false;
		}
	}

	public path function create(){
		if(this.exists()){
		} else {
			directoryCreate(variables.directory, true);			
		}
		return this;
	}

	public boolean function isDirectory(){
		return true;
	}

	public boolean function isFile(){
		return false;
	}

	public path[] function list(recurse=true, listInfo="query", filter="*", sort="Directory", type="all"){
		var files = directoryList(variables.directory, arguments.recurse, arguments.listInfo, arguments.filter, arguments.sort);
		var out = [];
		for(var file in files){
			if(file.type == "Dir"){
				out.append(new directory(file.directory));
			} else {
				out.append(new file("#file.directory#/#file.name#"));
			}
		}
		return out;
	}

	public string function toString(){
		return variables.directory;
	}

	private function cleanDoubleSlash(directory){
		return arguments.directory.replaceNoCase("//", "/", "all");
	}





}