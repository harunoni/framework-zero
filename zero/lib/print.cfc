/**
 * Prints value objects to the output buffer
 */
component {
	property name="value";
	
	public function init(required any value=""){
		variables.value = arguments.value;
		return this.toString();
	}

	/**
	 * toString method will abstract over the any type passed into the component
	 * @return {[type]} [description]
	 */
	public function toString(){
		if(isSimpleValue(variables.value)){
			return variables.value;
		}

		if(isComponentObject(variables.value)){

			if(objectHasToString(variables.value)){
				return variables.value.toString();
			} else {
				throw("Could not print the object #getName(variables.value)# because it does not have a toString() method");
			}
		}
	}

	private function isComponentObject(value){
		if(isObject(arguments.value) and isInstanceOf(arguments.value, "component")){
			return true;
		} else {
			return false;
		}
	}

	private function objectHasToString(required object object){

		// var componentMetaData = new componentMetaData(object);
		// writeDump(componentMetaData);

		if(structKeyExists(arguments.object, "toString")){

			if(isClosure(arguments.object.toString) OR isCustomFunction(arguments.object.toString)){
				return true;				
			} else {
				return false;
			}

		} else {
			return false;
		}
	}

	private function getName(required component object){
		return getMetaData(arguments.object).name;
	}

}