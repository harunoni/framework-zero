component extends="valueObject" {
	public valueObject function init(any value){
		left = listFirst(value,".");
		right = listLast(value,".");
		if(isNumeric(value) and left != "" and right >= 0 and right != ""){
			variables.value = arguments.value;
		} else {
			throw("The value passed for a double must be in the format 0000.0000");
		}		
	}
}