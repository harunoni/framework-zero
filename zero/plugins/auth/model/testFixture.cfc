import auth.model.orm.emailAddress;
import zero.validations.*;
component {

	public function init(auth auth){
		if(arguments.keyExists("auth")){
			variables.auth = arguments.auth;
		}
	}

	public Auth function createAuth(){
		var auth = variables.auth?: entityNew("auth");
		entitySave(auth);
		return auth;
	}

	public User function createAuthUser(){
		var Auth = createAuth();
		var User = Auth.createUser(new emailAddress("test@test.com"));
		return User;
	}

	public User[] function createThreeUsers(){

		var users = []
		var Auth = createAuth();
		users.append(Auth.createUser(emailAddress: new emailAddress("test1@test.com"), password: new password255("123456")));
		users.append(Auth.createUser(emailAddress: new emailAddress("test2@test.com"), password: new password255("123456")));
		users.append(Auth.createUser(emailAddress: new emailAddress("test3@test.com"), password: new password255("123456")));
		return users;
	}

	public struct function createLogin(){
		var User = createAuthUser();
		var creds = User.createPersistentLogin(10);

		var out = {
			user:User,
			creds:creds
		}
		// var out = {}
		return out;
	}

}