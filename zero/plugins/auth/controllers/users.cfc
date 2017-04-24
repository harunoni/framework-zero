import auth.model.orm.ormUtil;
import auth.model.orm.emailAddress;
import auth.util.querystring.querystring;
component accessors="true" extends="base" {

	//Parameter which can be overriden by other subsystems specifying the entityName of the auth entities
	param name="request.extendAuthResource" default="resources";

	public any function init( fw ) {

		variables.fw = fw;
		return this;
	}

	public struct function list(zeroTableFields users = new zero.validations.zeroTableFields(tableName="users"))
		description="Display, search and filter the users on the system"
	{
		var ZeroAuth = variables.fw.getZeroAuth();
		var usersTable = new zerotables.users.table();
		var usersTable.updateWithZeroTableFields(arguments.users);
    	var out = {
    		data:{
    			"users":usersTable.toJson()
    		}
    	}
    	return out;
	}

	public struct function new(){
		return {}
	}

	public struct function delete(required numeric id){
		var ZeroAuth = variables.fw.getZeroAuth();
		var User = ZeroAuth.findUserById(arguments.id).elseThrow("Could not locate that user");
		transaction {
			ZeroAuth.deleteUser(User);
			ORMFlush();
			transaction action="commit";
		}
		var out = {
			"success":true,
			"message":"The user was successfully deleted"
		}
		return out;
	}

	public struct function send_login(required numeric id){
		var ZeroAuth = variables.fw.getZeroAuth();
		var User = ZeroAuth.findUserById(arguments.id).elseThrow("Could not locate that user");
		var publicKey = User.createTemporaryLogin();
		transaction {

			var message = "Hello, please go to the link #cgi.server_name#/auth/logins/#publicKey# to set your password;"
			var Email = ZeroAuth.createEmail(plainContent=message, htmlContent=message);
			User.sendLogin(Email);
			ORMFlush();
			transaction action="commit";
		}
		var out = {
			"success":true,
			"message":"The login email was successfully sent"
		}
		return out;
	}

	public struct function create(	required emailAddress emailAddress,
							required varchar255 firstName,
							required varchar255 lastName,
							required password255 password

						  ){
		var ZeroAuth = variables.fw.getZeroAuth();
		if(ZeroAuth.findUserByEmailAddress(arguments.emailAddress).exists()){
			throw("A user with that email address already exists");
		}

		transaction {
			var User = ZeroAuth.createUser(emailAddress = arguments.emailAddress,
										   firstName = arguments.firstName,
										   lastName = arguments.lastName,
										   password = arguments.password);
			ORMFlush();
			transaction action="commit";
		}
		var out = {
			"success":true,
			"message":"The user was successfully created",
			"data":{
				"user":variables.fw.serialize(User)
			}
		}
		return out;
	}

	public struct function update( required numeric id,
							varchar255 firstName,
							varchar255 lastName,
							password255 password ){

		var ZeroAuth = variables.fw.getZeroAuth();
		var User = ZeroAuth.findUserById(arguments.id).elseThrow("Could not locate that user");
		arguments.user = User;
		transaction {
			ZeroAuth.updateUser(argumentCollection=arguments);
			ORMFlush();
			transaction action="commit";
		}

		var out = {
			"success":true,
			"message":"The user was successfully updated",
			"data":{
				"user":variables.fw.serialize(User)
			}
		}
		return out;
	}

	private function setPermissions(rc){
		for(local.resourceId in rc.resourceids)
		{
			local.resourceEnabled = rc.resourceids[local.resourceid];
			//Get the resource name from the hidden field, this makes it easy to loop through
			local.resourceName = lcase(rc.resourcenames[local.resourceid]);

			//If the resource is set to 0, that means it should be off. We first need to check if the user has this resource
			if(local.resourceEnabled IS 0)
			{
				//If the use has the resource, then it needs to be removed
				if(rc.user.hasResource(local.resourceName))
				{
					rc.user.removeResource(local.resourceName);
				}
			}
			else //If the resource needs to be enabled
			{
				//check if the user does not yet have the resource
				if(NOT rc.user.hasResource(local.resourceName))
				{
					//If they do not, load the resource so that we can add it to the account
					local.resource = new ormUtil().load(request.extendAuthResource,local.resourceId,true);

					rc.user.addResource(local.resourceName,local.resource);
					local.resource.addUser(rc.user);
					rc.user.save();
					local.resource.save();

				}
			}
		}
	}

	public struct function read( required numeric id ) {
		var ZeroAuth = variables.fw.getZeroAuth();
		var User = ZeroAuth.findUserById(arguments.id).elseThrow("Could not locate that user");
		var out = {
			"success":true,
			"message":"The user was successfully loaded",
			"data":{
				"user":variables.fw.serialize(User, {logins:{}, roles:{resources:{}}, availableRoles:{}})
			}
		}

		//Decorate any Role resources which are not active on the user
		for(var role in out.data.user.roles){

			for(var resource in role.resources){

				if(User.hasResource(resource.name)){
					resource.user_active = true
				} else {
					resource.user_active = false;
				}
			}
		}

		return out;
	}

	public struct function link(numeric roles_id, numeric resources_id, numeric id){

		var ZeroAuth = variables.fw.getZeroAuth();
		var User = ZeroAuth.findUserById(arguments.id).elseThrow("Could not load that user");

		if(arguments.keyExists("roles_id")){
			var Role = ZeroAuth.findRoleById(arguments.roles_id).elseThrow("Could not load that user");
			transaction {
				Role.addUser(User);
				ORMFlush();
				transaction action="commit";
			}

			var out = {
				"success":true,
				"message":"The user has been successfully added to the role",
			}
			return out;
		}

		if(arguments.keyExists("resources_id")){
			var Resource = ZeroAuth.findResourceById(arguments.resources_id).elseThrow("Could not load that user");
			transaction {
				Resource.addUser(User);
				ORMFlush();
				transaction action="commit";
			}

			var out = {
				"success":true,
				"message":"The user has been successfully added to the resource",
			}
			return out;
		}
	}

	public struct function unlink(numeric roles_id, numeric resources_id, numeric id){

		var ZeroAuth = variables.fw.getZeroAuth();
		var User = ZeroAuth.findUserById(arguments.id).elseThrow("Could not load that user");

		if(arguments.keyExists("roles_id")){
			var Role = ZeroAuth.findRoleById(arguments.roles_id).elseThrow("Could not load that user");
			transaction {
				Role.removeUser(User);
				ORMFlush();
				transaction action="commit";
			}

			var out = {
				"success":true,
				"message":"The user has been successfully removed from the role",
			}
			return out;
		}

		if(arguments.keyExists("resources_id")){

			var Resource = ZeroAuth.findResourceById(arguments.resources_id).elseThrow("Could not load that user");
			transaction {
				Resource.removeUser(User);
				ORMFlush();
				transaction action="commit";
			}

			var out = {
				"success":true,
				"message":"The user has been successfully removed from the resource",
			}
			return out;
		}
	}

}
