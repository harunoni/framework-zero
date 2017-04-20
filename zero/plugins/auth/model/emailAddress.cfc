component extends="valueObject" {

	property name="email";

	public emailAddress function init(required string email){

		if(!isValid("email", arguments.email)){
			variables.email = arguments.email;
			//For now commenting out because the auth views are not able to handle this
			// throw("That is not a valid email address");
		} else {
			variables.email = arguments.email;
		}
		return this;
	}
}