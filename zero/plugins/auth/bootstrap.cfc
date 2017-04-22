component {

	public function init(fw, storage=session, required string subsystemScope, required array subsystems, hasSuperUsers=false){
		variables.fw = arguments.fw;
		variables.storage = arguments.storage;
		variables.subsystemScope = arguments.subsystemScope;
		variables.hasSuperUsers = arguments.hasSuperUsers;

		if(cgi.path_info IS "/logout"){
			this.logoutUser();
			location url="/" addtoken="false";
		}

		if(subsystemScope == "denyAllExcept"){
			if(arrayContains(subsystems, fw.getSubsystem())){
				//Early return to skip authentication processing
				return;
			}
		}

		if(subsystemScope == "allowAllExcept"){

			if(arrayContains(subsystems, fw.getSubsystem())){
				//Do nothing, authentication processing will continue
			} else {
				//Early return to skip authentication processing
				return;
			}
		}


		if(variables.fw.getSubsystem() == "auth" and variables.fw.getSection() == "logins"){
			//User may be trying to login so we do not
			//enforece authentication
		} else {

			//User is not trying to login so we must enforce authentication
			if(this.hasLoginCredentials()){

				var LoginOptional = this.tryLogin();
				if(LoginOptional.exists()){
					//Basic user is validated. You can do additional
					//checks of the user resources and roles here
				} else {
					location url="/auth/logins" addtoken="false";
				}
			} else {
				location url="/auth/logins?redirect_to=#cgi.path_info#" addtoken="false";
			}
		}

		return this;
	}

	public function generateSubsystemResources(){
		var subsystems = variables.fw.getSubsystemData();
		var ZeroAuth = getZeroAuth();

		if(variables.hasSuperUsers){
			transaction {
				ZeroAuth.setHasSuperUsers(true);
				ORMFlush();
				transaction action="commit";
			}
		}

		transaction {
			for(var subsystemName in subsystems){

				var subsystemResource = ZeroAuth.createOrLoadResource(subsystemName, "#subsystemName# module");

				for(var sectionName in subsystems[subsystemName]){
					var sectionResource = ZeroAuth.createOrLoadResource("#subsystemName#:#sectionName#", "#subsystemName#:#sectionName# section", subsystemResource);

					var funcs = variables.fw.getAllExtendedFunctions(subsystems[subsystemName][sectionName]);
					for(var func in funcs){

						if(func.access == "public"){
							//Only public functions get resources
							//because they are the only functions which could have
							//routes
							itemResource = ZeroAuth.createOrLoadResource("#subsystemName#:#sectionName#.#func.name#",
																		 "#subsystemName#:#sectionName#.#func.name# item #func.description#",
																		 sectionResource);
						}

					}
				}
			}
			ORMFlush();
			transaction action="commit";
		}
	}

	public function getZeroAuth(){

		if(structKeyExists(variables.fw, "getzeroauth")){
			return variables.fw.getZeroAuth();
		} else {
			var auth = entityLoad("auth");
			if(arrayLen(auth) == 0){
				transaction {
					var auth = entityNew("auth");
					entitySave(auth);
					ORMFlush();
					transaction action="commit";
				}

			} else {
				var auth = auth[1];
			}
			return auth;
		}
	}

	public function hasLoginCredentials(){
		var headers = getHTTPRequestData().headers;

		if(structKeyExists(variables.storage,"token") and structKeyExists(variables.storage,"authentication")){
			return true;
		} else if(headers.keyExists("token") and headers.keyExists("authentication")){
			return true;
		}
		else {
			return false;
		}
	}

	public function getLoginCredentials(){
		var headers = getHTTPRequestData().headers;
		if(structKeyExists(variables.storage,"token") and structKeyExists(variables.storage,"authentication")){
			return {
				token:variables.storage.token,
				authentication:variables.storage.authentication
			}
		} else if(headers.keyExists("token") and headers.keyExists("authentication")){
			return {
				token:headers.token,
				authentication:headers.authentication
			}
		}
	}

	public Optional function tryLogin(){

		if(!hasLoginCredentials()){
			throw("Could not find login credentials");
		} else {
			var Auth = this.getZeroAuth();
			var creds = getLoginCredentials();
			LoginOptional = Auth.findLogin(creds.token, creds.authentication);
			if(LoginOptional.exists()){
				return LoginOptional;
			} else {
				//Creds must be invaid, so delete them before returning the optional
				structDelete(variables.storage,"token");
				structDelete(variables.storage,"authentication");
				return LoginOptional;
			}
		}
	}

	public boolean function loginUser(required string email, required string password){
		var Auth = this.getZeroAuth();
		userOptional = Auth.findUser(arguments.email);
		if(userOptional.exists()){
			var User = userOptional.get();
			if(User.checkPassword(arguments.password)){
				transaction {
					var creds = User.createPersistentLogin(1);
					transaction action="commit";
				}
				variables.storage.token = creds.token;
				variables.storage.authentication = creds.authentication;
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	public void function logoutUser() throws="loginNotAuthorized"{
		if(hasLoginCredentials()){
			var LoginOptional = tryLogin();
			if(!LoginOptional.exists()){
				//Do nothing, was not a valid user
			} else {
				transaction {
					var Login = LoginOptional.get();
					var Auth = this.getZeroAuth();
					Auth.deleteLogin(Login);
					ORMFlush();
					transaction action="commit";
				}
			}
		}
	}

}