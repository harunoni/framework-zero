/**
*/
component extends="baseValidation" {

	public function init(formElement){

		if(!formElement.hasAttr("method")){
			variables.is_success = false;
			variables.message = "The form did not have a method attribute. method='GET' or method='POST' is required";

		} else {
			var method = formElement.attr('method');
			if(lcase(method) == "get" or lcase(method) == "post"){
				variables.is_success = true;
			} else {
				variables.is_success = false;
				variables.message = "The form method attribute was incorrect. Must be method='GET' or method='POST'";
			}
		}

		return this;
	}
}