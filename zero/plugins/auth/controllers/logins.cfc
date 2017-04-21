component accessors="true" extends="base"{

	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	public function create( required emailAddress emailAddress,
							required password255 password ) {

		var ZeroAuth = variables.fw.getZeroAuth();
		var User = ZeroAuth.findUserByEmailAddress(arguments.emailAddress).elseThrow("The email address or password you supplied is not valid, please try again.");

		if(User.checkPassword(arguments.password) == false){
			throw("The email address or password you supplied is not valid, please try again.");
		} else {
			transaction {
				var credentials = User.createPersistentLogin(30);
				ORMFlush();
				transaction action="commit";
			}
			var out = {
				"success":true,
				"message":"The login was successfully created",
				"data":{
					"token":credentials.token,
					"authentication":credentials.authentication
				}
			}
			return out;
		}
	}

	public struct function list(string redirect_to="/"){
		if(redirect_to == ""){
			redirect_to = "/";
		}
		return {
			"success":true,
			"data":{
				"redirect_to":arguments.redirect_to?:"/"
			}
		};
	}

	public function read(id){

		variables.fw.setView("auth:logins.list");
		var ZeroAuth = variables.fw.getZeroAuth();
		var tempLogin = ZeroAuth.findTempLogin(id).elseThrow("Could not find that login");
		var User = tempLogin.getUser();
		var out = {
			"success":true,
			"message":"Please complete your signup",
			"data":{
				"user":variables.fw.serialize(User),
				"id":arguments.id,
				"goto":"/"
			}
		}
		return out;
	}

	public struct function result(controllerResult){

		if(request.action == "auth:logins.create"){

			if(controllerResult.success){
				cookie.token = controllerResult.data.token;
				cookie.authentication = controllerResult.data.authentication;
			}
		}

		if(request.action == "auth:logins.delete"){
			if(controllerResult.success){
				if(cookie.keyExists("token")){structDelete(cookie, "token")}
				if(cookie.keyExists("authentication")){structDelete(cookie, "authentication")}
			}
		}

		return arguments.controllerResult;
	}

	public function delete(required string token, required string authentication){
		var ZeroAuth = variables.fw.getZeroAuth();
		var Login = ZeroAuth.findLogin(arguments.token, arguments.authentication).elseThrow("User was not logged in");
		transaction {
			ZeroAuth.deleteLogin(Login);
			ORMFlush();
			transaction action="commit";
		}
		var out = {
			"success":true,
			"message":"The login has been successfully deleted"
		}
		return out;
	}

	public struct function update(	required string id,
							required password255 password,
							required password255 confirmPassword){

		if(!(password.equals(confirmPassword))){
			throw("Passwords were not identical");
		}

		var zeroAuth = variables.fw.getZeroAuth();
		var tempLogin = ZeroAuth.findTempLogin(id).elseThrow("Could not find that login");
		var User = tempLogin.getUser();
		transaction {
			ZeroAuth.updateUserTempPassword(User: User, TempLogin: TempLogin, Password: arguments.Password)
			ORMFlush();
			transaction action="commit";
		}

		var out = {
			"success":true,
			"message":"The password has been successfully updated"
		}
		return out;
	}


	private function updatePassword(rc){



	}

}
