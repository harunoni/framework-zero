component extends="valueObject" {
	public valueObject function init(any value){
		int(arguments.value);
		variables.value = arguments.value;
		return this;
	}
}