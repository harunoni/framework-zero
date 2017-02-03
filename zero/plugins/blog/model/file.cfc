/**
*/
component implements="path" {
	public function init(required string file){
		variables.file = arguments.file;
		return this;
	}

	public boolean function exists(){
		return fileExists(variables.file);
	};
	
	public path function create(){

	};

	public string function toString(){
		return variables.file;
	};

	public directory function getDirectory(){
		return new directory(getDirectoryFromPath(variables.file));
	}

	public fileName function getFileName(){
		var fileName = new fileName(getFileFromPath(variables.file));
		return fileName;
	}

	public boolean function isDirectory(){
		return false;
	}

	public boolean function isFile(){
		return true;
	}
}