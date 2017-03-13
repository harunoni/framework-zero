component extends="valueObject" {

	public function init(required value){		
    if(lsIsCurrency(arguments.value)) {
      variables.value = arguments.value;
      variables.value = replaceNoCase(variables.value, "$", "", "all");
    } else {
      throw('You must use a valid currency in the form of $0.00');
    }
		return this;
	}

	public function getChange(){
		return listLast(variables.value, ".");
	}  

}