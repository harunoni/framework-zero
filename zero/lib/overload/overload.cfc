/**
 * Implements method overloading for Lucee
 */
component {

	public function init(required component object){
		variables.object = arguments.object;
		return this;
	}

	public func function find(required struct args){

		var metaData = new objectMetaData(variables.object);	
		var funcs = metaData.getFuncs();

		//Find exact match
		
		for(var func in funcs){
			if(func.argumentsMatch(args)){

			}
		}

		return new func();
	}

}