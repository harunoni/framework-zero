/**
*/
component implements="validation,formElement,cfc,cfcMethod,urlArguments" {
	public function init(required formElement, required component cfc, required string cfcMethod, struct urlArguments){

		var metaData = getMetaData(cfc);
		var cfcMethod = arguments.cfcMethod;
		new missingControllerMethod(formElement, cfc, cfcMethod);

		var foundFunc = metaData.functions.find(function(_func){
			if(_func.name == cfcMethod){
				// return _func;
				return true;
			} else {
				return false;
			}
		});

		funcs = metaData.functions[foundFunc];
		//Check all required contorller method arguments
		for(var param in funcs.parameters){
			if(param.required){
				var inputs = formElement.select("input[name='#param.name#'],select[name='#param.name#']");
				// writeDump(inputs);
				if(arrayLen(inputs) == 0){

					if(arguments.urlArguments.keyExists(param.name)){
						//The argument was in the URL path or query string and therefore is
						//acceptable for this form
					} else {
						throw("Form was missing a required input #param.name#", "missingRequiredInputs");
					}

				} else {

					for(var input in inputs){
						if(!input.hasAttr('value')){
							throw("Required input '#param.name#' for #metaData.fullName#:#cfcMethod#() was missing a value attribute", "requiredInputMissingValue");
						}
					}

				}
			}
		}

		return this;
	}
}