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

	public struct function createResources(){
		var Auth = createAuth();
		var res1 = auth.createOrLoadResource("res1", "test res1");
		var res2 = auth.createOrLoadResource("res2", "test res2", res1);
		var res3 = auth.createOrLoadResource("res3", "test res3", res1);
		var res4 = auth.createOrLoadResource("res4", "test res4");
		return Auth;
	}

	public struct function createRoles(){
		var Auth = createAuth();
		var role1 = Auth.createOrLoadRole(new roleName("role 1"), new roleDescription("A role 1"));
		var role2 = Auth.createOrLoadRole(new roleName("role 2"), new roleDescription("A role 2"));
		var role3 = Auth.createOrLoadRole(new roleName("role 3"), new roleDescription("A role 3"));
		return Auth;
	}

}