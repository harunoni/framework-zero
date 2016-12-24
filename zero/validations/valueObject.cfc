component implements="zero.lib.printable" {	
	property name="value";
	public valueObject function init(required value){
		variables.value = arguments.value;
		return this;
	}

	public string function toString(){
		return variables.value;
	}
}