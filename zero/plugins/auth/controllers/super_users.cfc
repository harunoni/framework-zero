component accessors="true" {

	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	public struct function list(){
		return {}
	}

	public struct function create(required emailAddress emailAddress, required password255 password, varchar255 firstName, varchar255 lastName, userType="user"){
		ZeroAuth = variables.fw.getZeroAuth();
		var User = ZeroAuth.findUserByEmailAddress(arguments.emailAddress);
		if(!User.exists()){
			transaction {
				var user = {
					emailAddress: arguments.emailAddress,
					firstName: arguments.firstName?:new zero.validations.varchar255(""),
					lastName: arguments.lastName?: new zero.validations.varchar255(""),
					password: arguments.password,
					userType: arguments.userType
				}

				var User = ZeroAuth.createUser(argumentCollection=user);
				var superUserRole = ZeroAuth.createOrLoadRole(new zeroauth.model.roleName("Super Users"), new zeroauth.model.roleDescription("A role for users which should have access to all resources"));
				superUserRole.addUser(User);
				ORMFlush();
				transaction action="commit";
			}
		}
		var out = {
			"success":true,
			"messge":"The super user was created, you can now log in",
			"data":{
				"user":variables.fw.serialize(User)
			}
		}
		return out;
	}

	public struct function read( required id ) {
		return {};
	}

	public struct function update( required id ) {
		return {};
	}

	public struct function delete( required id ) {
		return {};
	}

	/**
	 * Function to override the request scope variables for this controller
	 * @param  {struct} rc The request context, the URL and FORM variables passed into the app
	 * @return {struct}    The update RC scope which will be used to find variables for the controllers
	 */
	public struct function request( required struct rc, required struct headers ){
		ZeroAuth = variables.fw.getZeroAuth();
		if(ZeroAuth.getHasSuperUsers() == false){
			throw("App is not configured for super users");
		}
		return rc;
	}

	/**
	 * A function to override all controller function responses, for example to decorate with extra information on every call
	 * @param  {struct} required struct        controllerResult Will receive the result of the controller method (list, create, read etc)
	 * @return {struct}          Should return the updated controller result
	 */
	public struct function result( required struct controllerResult ){
		return controllerResult;
	}

}
