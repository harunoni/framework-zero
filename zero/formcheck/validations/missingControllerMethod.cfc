/**
*/
component implements="validation,formElement,cfc,cfcMethod"  {
	public function init(required formElement, required component cfc, required string cfcMethod){

		var metaData = getMetaData(cfc);
		var cfcMethod = arguments.cfcMethod;
		// abort;
		var foundFunc = metaData.functions.find(function(_func){
			if(_func.name == cfcMethod){
				// return _func;
				return true;
			} else {
				return false;
			}
		});

		if(foundFunc == 0){
			throw("Could not find the method #cfcMethod# in controller #metaData.fullName#", "missingControllerMethod");
		}
		return this;
	}
}