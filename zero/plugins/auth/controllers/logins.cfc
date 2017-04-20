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

	public struct function list(string goto){
		return {
			"success":true,
			"data":{
				"goto":arguments.goto?:"/"
			}
		};
	}

	public function read(id){

		var ZeroAuth = variables.fw.getZeroAuth();
		var userHash = listFirst(arguments.id,":");
		var passcode = listLast(arguments.id,":");
		var tempLogin = ZeroAuth.findTempLogin(userHash, passcode).elseThrow("Could not find that login");
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
		variables.fw.setView("auth:logins.list");
		return out;
	}

	public struct function result(controllerResult){
		if(request.action == "auth:logins.create"){
			cookie.token = controllerResult.data.token;
			cookie.authentication = controllerResult.data.authentication;
		}
		return arguments.controllerResult;
	}

	public function update(rc){
		//Check if the user is trying to update the password for the user
		if(structKeyExists(rc,"password") AND structKeyExists(rc,"confirmpassword")){

			if(compare(rc.password,rc.confirmpassword) IS 0){
				var userHash = listFirst(rc.id,":");
				var passcode = listLast(rc.id,":");
				var login = entityLoad("tempLogins",{userHash:userHash, passcode:new saltedHash(userHash, passcode)}, true);

				if(isNull(login)){
					writeOutput("There is no login with those credentials");
					abort;
				} else {
					rc.user = login.getUser();
					rc.user.setPassword(rc.password);
					rc.user.removeLogin(login);
					entityDelete(login);
					entitySave(rc.user);
					ORMFlush();
					rc.email = rc.user.getEmail();
					rc.message = "You have successfully set your password, for security purposes please sign in with your password now";
					variables.fw.redirect(action="logins.default", preserve="message,email");
				}

			} else {
				rc.message = "Your passwords do not match"
			}
		}
	}

	private function updatePassword(rc){



	}

	public void function default( rc ) {

       structClear(cookie); //Clear the cookies in case they have old ones

      	 //writeLog(file="silentredirect",text="while in action.login called from #callStackGet()[2].template# #callStackGet()[2].function# #callStackGet()[2].lineNumber#");
		//Check for create password login form

		// if(structKeyExists(rc,"login") AND structKeyExists(rc,"loginid") AND isValid("UUID",rc.loginid))
		// {
		// 	local.user = new ormUtil().load("users",{tempLogin:rc.loginid},true);
		// 	if(isObject(local.user))
		// 	{
		// 		if(rc.password IS rc.confirmpassword)
		// 		{
		// 			local.user.setPassword(rc.password);
		// 			variables.session.loginUser(local.user);
		// 			param name="rc.length" default="1";
		// 			local.auth = local.user.createPersistentLogin(rc.length);
		// 			variables.session.setPersistentLogin(local.auth.authentication,local.auth.token,rc.length);
		// 			location url="#local.user.getAccount().getAdminPath()#" addtoken="false";
		// 		}
		// 	}
		// }
		// else if(structKeyExists(rc,"loginid") AND isValid("UUID",rc.loginid)){
		// 	rc.user = variables.activeRecord.createOrload("users",{tempLogin:rc.loginid},true);
		// }

		//Check for normal login form
		if(structKeyExists(rc,"login") AND structKeyExists(rc,"password") AND structKeyExists(rc,"email"))
		{
			writeDump(rc);
			abort;
			local.user = new ormUtil().load("users",{email:rc.email},true);
			if(isObject(local.user))
			{
				if(local.user.checkPassword(rc.password))
				{
					variables.session.loginUser(user);

					param name="rc.length" default="1";
					local.auth = local.user.createPersistentLogin(rc.length);
					variables.session.setPersistentLogin(local.auth.authentication,local.auth.token,rc.length);
					location url="#local.user.getAccount().getAdminPath()#" addtoken="false";
					//variables.fw.redirect(rc.action,true);
				}
			}
		}
	}

}
