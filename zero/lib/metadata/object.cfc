/**
 * Represents component meta data
 */
component accessors="true" extends="struct" {

	property name="functions" setter="false";
	// property name="name" type="name";
	// property name="hint" setter="false";
	// property name="path" setter="false";
	// property name="persistent" setter="false";


	public function init(required component object){
		variables.object = arguments.object;
		variables.data = getMetaData(variables.object);
		return this;
	}	

	public function toStruct(){
		return variables.data;
	}

	public func[] function getFunctions(){
		var out = [];
		for(var data in variables.data.functions){
			out.append(new func(data));
		}
		return out;
	}

}