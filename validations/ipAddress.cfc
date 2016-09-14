component extends="valueObject" {

	public valueObject function init(name, any value){
		var regex = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
		if(!reFind(regex, value, 1)){
			throw("The value passed for #name# is not a valid IP address");
		}
		return this;
	}

}