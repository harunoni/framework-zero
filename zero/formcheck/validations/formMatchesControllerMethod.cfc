/**
*/
component extends="baseValidation" {
	public function init(required formElement, required component cfc, required string cfcMethod){

		var metaData = getMetaData(cfc);
		var cfcMethod = arguments.cfcMethod;
		var foundFunc = metaData.functions.find(function(_func){
			if(_func.name == cfcMethod){
				// return _func;
				return true;
			} else {
				return false;
			}
		});

		if(foundFunc == 0){
			variables.is_success = false;
			variables.message = "Could not find the method #cfcMethod# in controller #metaData.fullName#";
			return;
		}

		funcs = metaData.functions[foundFunc];
		//Check all required contorller method arguments
		for(var param in funcs.parameters){
			if(param.required){
				var inputs = formElement.select("input[name='#param.name#'],select[name='#param.name#']");
				// writeDump(inputs);
				if(arrayLen(inputs) == 0){
					variables.is_success = false;
					variables.message = "Form was missing a required input #param.name#";
					return;
				} else {

					for(var input in inputs){
						if(!input.hasAttr('value')){
							variables.is_success = false;
							variables.message = "Required input '#param.name#' for #metaData.fullName#:#cfcMethod#() was missing a value attribute";
						}
					}

				}


			}
		}

		return this;
	}
}