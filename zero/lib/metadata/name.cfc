/**
*
*/
component {
	public function init(value){
		variables.value = arguments.value;
		return this;
	}
	
	public string function toString(){
		return variables.value;
	}
	
	public boolean function equals(required component object){
		return arguments.object.toString() == this.toString();
	}
}