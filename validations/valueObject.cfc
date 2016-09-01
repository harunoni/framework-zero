component {	
	property name="value";
	public function init(required value){
		variables.value = arguments.value;
		return this;
	}

	public function toString(){
		return variables.value;
	}
}