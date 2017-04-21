/**
 * Represents a domain for authorization. This is the root entity
 */
component persistent="true" table="auth" output="false" accessors="true" discriminatorColumn="auth_extended_by" discriminatorValue="auth" {
	/* properties */
	property name="id" column="auth_id" type="numeric" ormtype="int" fieldtype="id" generator="identity";

	property name="accounts" fieldtype="one-to-many" cfc="accounts" fkcolumn="auth_id" singularname="account";
	property name="users" fieldtype="one-to-many" cfc="user" fkcolumn="auth_id" singularname="user";
	property name="roles" fieldtype="one-to-many" cfc="roles" fkcolumn="auth_id" singularname="role";
	property name="resources" fieldtype="one-to-many" cfc="resources" fkcolumn="auth_id" singularname="resource";

	//Default emailer properties that apply to the whole auth domain
	property name="emailServer" column="email_server" default="" sqltype="varchar(255)" dbdefault="";
	property name="emailUseTLS" column="email_use_tls" default="" sqltype="varchar(255)" dbdefault="";
	property name="emailPassword" column="email_password" default="" sqltype="varchar(255)" dbdefault="";
	property name="emailPort" column="email_port" default="" sqltype="varchar(255)" dbdefault="";
	property name="emailUsername" column="email_username" default="" sqltype="varchar(255)" dbdefault="";

	variables.users = variables.users?:[];
	variables.accounts = variables.accounts?:[];
	variables.roles = variables.roles?:[];
	variables.roles = variables.roles?:[];

	public array function getExtendedAccountTypes(){
		var result = new extendedEntityMetaData("accounts").getChildEntityNames();
		return result;
	}

	/**
	 * Creates a new account on this auth domain
	 * @param  {String} required string        accountType [description]
	 * @return {[type]}          [description]
	 */
	public Accounts function newAccount(required string accountType="accounts"){
		var accountType = arguments.accountType;
		var accountTypes = getExtendedAccountTypes();
		if(!accountTypes.containsNoCase(accountType)){
			throw("#accountType# is not a valid account type in the system");
		} else {
			var account = entityNew(accountType);
			account.setAuth(this);
			this.addAccount(account);
			return account;
		}
	}

	public Roles function newRole(required string roleName){

		var role = entityNew("roles", {name:lcase(arguments.roleName)});
		entitySave(role);
		this.addRole(role);
		role.setAuth(this);
		return role;
	}

	public function getRoleByName(required string name){

		var role = ORMExecuteQuery("select r from roles r join r.auth a where r.name = '#lcase(arguments.name)#' and a.id = #this.getId()#", true);
		return role;
	}

	public Email function createEmail(	required string emailServer = variables.emailServer,
										required string emailUseTLS = variables.emailUseTLS,
										required string emailPassword = variables.emailPassword,
										required string emailPort = variables.emailPort,
										required string emailUsername = variables.emailUsername,
										required string plainContent,
										required string htmlContent

										){

		var Email = entityNew("email");
		Email.setServer(arguments.emailServer);
		Email.setUseTLS(arguments.emailUseTLS);
		Email.setPassword(arguments.emailPassword);
		Email.setPort(arguments.emailPort);
		Email.setUsername(arguments.emailUsername);
		Email.setPlainContent(arguments.plainContent);
		Email.setHTMLContent(arguments.htmlContent);
		entitySave(Email);
		return Email;
	}

	public User function createUser(required emailAddress emailAddress,
								  varchar255 firstName,
								  varchar255 lastName,
								  password255 password,
								  userType="user"){
		// writeDump(arguments);
		var userType = arguments.userType;
		var args = arguments;
		structDelete(args,"userType");

		var User = entityNew(userType);
		args.User = User;
		this.updateUser(argumentCollection=args);
		this.addUser(User);
		User.setAuth(this);
		entitySave(User);
		return User;
	}

	public void function deleteUser(required User User){
		if(this.hasUser(User)){
			User.setIsDeleted(true);
		}
	}

	public void function updateUser(required User User,
								  	emailAddress emailAddress,
								  	varchar255 firstName,
								  	varchar255 lastName,
								  	password255 password){

		var User = arguments.user;
		if(arguments.keyExists("emailAddress")){ User.setEmailAddress(arguments.emailAddress); }
		if(arguments.keyExists("firstName")){ User.setFirstName(arguments.firstName); }
		if(arguments.keyExists("lastName")){ User.setLastName(arguments.lastName); }
		if(arguments.keyExists("password")){ User.setPassword(arguments.password); }
	}

	/*
	Takes a user, tempLogin and password and updates the user,
	then deletes the tempLogin. Once a password has been updated,
	the tempLogin should be deleted for security purposes
	 */
	public void function updateUserTempPassword(required User User,
												required tempLogins TempLogin,
												required password255 password){

		updateUser(User: arguments.User, password: arguments.password);
		User.removeLogin(arguments.TempLogin);
		TempLogin.setUser(nullValue());
		entityDelete(tempLogin);
	}

	public Optional function findLogin(required string token, required string authentication){
		var Login = entityLoad("logins", {userHash:arguments.token, passcode:new saltedHash(arguments.token, arguments.authentication)}, true);
		if(isNull(Login)){
			return new Optional();
		} else {
			if(Login.checkPasscode(arguments.authentication)){
				return new Optional(Login);
			} else {
				return new Optional();
			}
		}
	}

	public Optional function findTempLogin(publicKey){
		var saltedKey = new saltedHash("publictemplogin", arguments.publicKey);
		var Login = entityLoad("tempLogins", {publicKey:saltedKey}, true);
		if(isNull(Login)){
			return new Optional();
		} else {
			return new Optional(Login);
		}
	}

	public void function deleteLogin(required Logins Login){
		transaction {
			var User = Login.getUser();
			User.removeLogin(Login);
			Login.setUser(nullValue());
			entityDelete(Login);
			ORMFlush();
			transaction action="commit";
		}
	}

	public Optional function findUser(required string email){
		return new Optional(entityLoad("user", {email:arguments.email}, true));
	}

	public Optional function findUserByEmailAddress(required emailAddress emailAddress){
		return new Optional(entityLoad("user", {emailAddress:arguments.emailAddress.toString()}, true));
	}

	public Optional function findUserById(required numeric id){
		return new Optional(entityLoad("user", {id:arguments.id}, true));
	}

}
