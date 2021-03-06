component {

	public function init(fw,
						 storage=session,
						 required string subsystemScope,
						 required array subsystems,
						 hasSuperUsers=false,
						 loginFormRoute,
						 ){

		variables.subsystems = arguments.subsystems;
		variables.fw = arguments.fw;
		variables.storage = arguments.storage;
		variables.subsystemScope = arguments.subsystemScope;
		variables.hasSuperUsers = arguments.hasSuperUsers;
		variables.loginFormRoute = arguments.loginFormRoute?:"/auth/logins";


		if(variables.hasSuperUsers){
			if(getZeroAuth().getHasSuperUsers() == false){
				transaction {
					getZeroAuth().setHasSuperUsers(true);
					ORMFlush();
					transaction action="commit";
				}
			}
		}

		/*Call getZeroAuth to setup getZeroAuth if it does
		not exist on the Zero passed in*/
		getZeroAuth();
		return this;
	}

	public Optional function getLoggedInUser(){

		if(request.keyExists("user")){
			return new model.Optional(request.user);
		} else {
			return new model.Optional();
		}
	}

	public void function authenticateWithSubsystemResources(){
		if(authenticate() == false){

			return;
		}

		var ZeroAuth = this.getZeroAuth();
		var resourceName = request.action;
		var Resource = ZeroAuth.findResourceByName(resourceName);
		if(Resource.exists()){
			var Resource = Resource.get();
			var User = getLoggedInUser().elseThrow("Invalid user login");
			if(!User.hasResource(Resource.getName().toString())){
				throw("Unauthorized", 400);
			}
		}
	}

	public boolean function authenticate() {
		var result = false;
		if (cgi.path_info IS "/logout") {
			this.logoutUser();
			location url="/" addtoken="false";
			return false;
		}
		if (variables.subsystemScope == "denyAllExcept") {

			if (arrayContains(variables.subsystems, variables.fw.getSubsystem())) {
				//Early return to skip authentication processing
				return false;
			}
		}

		if (variables.subsystemScope == "allowAllExcept") {
			if (arrayContains(variables.subsystems, variables.fw.getSubsystem())) {
				//Do nothing, authentication processing will continue
			} else {
				//Early return to skip authentication processing
				result = true;
			}
		}
		// writeDump(cgi);
		// abort;
		// if (variables.fw.getSubsystem() == "auth" and variables.fw.getSection() == "logins") {
		var currentPath = cgi.path_info;
		if(trim(currentPath) == ""){
			currentPath = "/"
		}
		if (currentPath == variables.loginFormRoute or (variables.fw.getSubsystem() == "auth" and variables.fw.getSection() == "logins")) {
			//User may be trying to login so we do not
			//enforece authentication
			result = false;
		} else {

			if(variables.fw.getSubsystem() == "auth" and variables.fw.getSection() == "super_users"){

				if(variables.hasSuperUsers){
					result = false;
				} else {
					result = true;
				}
			} else {
				//User is not trying to login so we must enforce authentication
				if (this.hasLoginCredentials()) {
					var LoginOptional = this.tryLogin();
					if (LoginOptional.exists()) {
						request.User = LoginOptional.get().getUser();
						//Basic user is validated. You can do additional
						//checks of the user resources and roles here
					} else {
						location url="#variables.loginFormRoute#" addtoken="false";
						result = false;
					}
				} else {
					location url="#variables.loginFormRoute#?redirect_to=#cgi.path_info#" addtoken="false";
					result = false;
				}
			}
		}
		return result;
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

				if(variables.subsystemScope == "denyAllExcept"){
					if(arrayContains(variables.subsystems, subsystemName)){
						//Do not protect this subsystem because it has been excepted
						continue;
					}
				}

				if(variables.subsystemScope == "allowAllExcept"){

					if(arrayContains(variables.subsystems, subsystemName)){
						//Do nothing, authentication processing will continue
					} else {
						//Allow this subsystem because it has been accepted
						continue;
					}
				}

				var subsystemResource = ZeroAuth.createOrLoadResource(subsystemName, "#subsystemName# module");

				for(var sectionName in subsystems[subsystemName]){

					var controllerMeta = subsystems[subsystemName][sectionName];
					var description = controllerMeta.description?:"#subsystemName#:#sectionName# section"
					var sectionResource = ZeroAuth.createOrLoadResource("#subsystemName#:#sectionName#", description, subsystemResource);

					var funcs = variables.fw.getAllExtendedFunctions(subsystems[subsystemName][sectionName]);
					for(var func in funcs){

						if(func.access == "public"){
							//Only public functions get resources
							//because they are the only functions which could have
							//routes

							//Igrnoe these methods which are either Lucee built in methods
							//or are Framework Zero methods
							var ignore=["init", "request", "result", "onMissingMethod"];
							if(ignore.containsNoCase(func.name)){
								continue;
							}

							var description = func.description?:"#subsystemName#:#sectionName#.#func.name# item #func.description#"
							itemResource = ZeroAuth.createOrLoadResource("#subsystemName#:#sectionName#.#func.name#",
																		 description,
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
			variables.fw.getZeroAuth = function(){
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
			return variables.fw.getZeroAuth();
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