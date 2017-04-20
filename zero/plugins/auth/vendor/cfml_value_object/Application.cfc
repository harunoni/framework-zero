component {

	rootDirectory = getDirectoryFromPath(getCurrentTemplatePath()) & "..";		
	this.mappings["/"] = rootDirectory;

}