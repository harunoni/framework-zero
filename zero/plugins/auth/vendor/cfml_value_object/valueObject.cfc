/**
** 
* @author Rory Laitila  
* @description Base class for implementing valueObjects in the Domain Driven Design paradigm. 
*
* Usage:
* Extend this class. It works by introspecting properties of your value object, and provides a couple of default functions that are useful for value objects
*
*/

component output="false" displayname="" {

	public function equals(required component Obj){

		var obj1 = serialize(this.toStruct());
		var obj2 = serialize(arguments.obj.toStruct());
		return obj1 == obj2;
	}	

	/**
	* Check the public properties on the valueObject and returns 
	* the value if there is one property and the property data is a simple Value. Otherwise
	* the valueObject should provide its own tostring method to serialize the appropriate value
	*/
	public function toString(){
		//Will inspect the properties and return the specific property value unless overidden by the child
		var properties = getMetaData(this).properties;
		if(properties.len() GT 1){
			throw("This value object has more than one property so we cannot return it to string. Create your own ToString method in the value object");
		}

		propertyValue = variables[properties[1].name];

		if(!isSimpleValue(propertyValue)){
			throw("The value was not a simple value and therefore cannot be converted to a string. Provide your own toString method in the value object");
		}

		return propertyValue;
	}


	/**
	 * Checks all of the properties and returns them in a structure, this is used in the equals function
	 * 
	 */
	public struct function toStruct(){
		//Will inspect the properties and return the specific property value unless overidden by the child
		var properties = getMetaData(this).properties;
		var propertiesOut = {};
		for(var property IN properties){
			propertiesOut[property.name] = variables[property.name];
		}
		return propertiesOut;		
	}

	public function length(){
		return this.toString().len();
	}

	public function serialize(){
		return serialize(this.toStruct());
	}
}