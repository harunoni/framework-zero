/**
 * Represents component meta data
 */
component accessors="true"{

	property name="funcs" setter="false";

	public function init(required component object){
		variables.object = arguments.object;
		variables.data = getMetaData(variables.object);
		return this;
	}	

	public function toStruct(){
		return variables.data;
	}

	public funcMetaData[] function getFuncs(){
		var out = [];
		for(var data in variables.data.functions){
			out.append(new funcMetaData(data));
		}
		return out;
	}
}