/**
*/
component extends="baseValidation"{

	public function init(htmlDoc, formElement){

		if(formElement.hasAttr('zero-target')){
			var target = formElement.attr('zero-target');
			var find = htmlDoc.select(target);
			if(arrayLen(find) == 0){
				variables.is_success = false;
				variables.message = "Could not find the expected element '#target#' for zero-target";
			}
		}

		return this;
	}
}