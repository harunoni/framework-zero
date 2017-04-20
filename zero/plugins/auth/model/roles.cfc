/*
Author: Rory Laitila

*/

component persistent="true" table="roles" output="false" accessors="true" discriminatorColumn="roles_extended_by" discriminatorValue="role"
{
	/* properties */

	property name="id" column="roles_id" type="numeric" ormtype="int" fieldtype="id" generator="identity";
	property name="name" column="roles_name" type="string" specTestValue="test.*";
	property name="description" column="roles_description" type="string" specTestValue="Category Manager";
	property name="type" column="roles_type" type="string" specTestValue="allow";

	property name="accounts" fieldtype="many-to-many" cfc="accounts" linktable="accounts_roles" singularname="account" inverse="true";
	property name="users" fieldtype="many-to-many" cfc="user" linktable="user_roles" singularname="user";
	property name="resources" fieldtype="many-to-many" cfc="resources" linktable="roles_resources" singularname="resource";
	property name="auth" fieldtype="many-to-one" cfc="auth" fkcolumn="auth_id" inverse="true";

	public function init(){

		//Swap methods that we are going to override to new private methods so that we can still use the ORM methods
		variables.__removeUser = this.removeUser;
		this.removeUser = variables._removeUser;
	}

	/**
	* Looks at the permissions related to this role and ensures that the user has all of them
	*/
	public function addUser(required component user){

		var user = arguments.user;
		var resources = this.getResources();

		//Because properties can be null on creation, if it is we set it to an empty array so that we can append to this later
		var user = ((isNull(variables.user)? []:variables.user));

		//Add the user to the role which was the original intent of addUser() generated method
		arrayAppend(user, user);

		//Now perform custom functionality to apply the resources this role has to the user
		for(var resource IN resources?:[]){
			if(!user.hasResource(resource.getName())){
				user.addResource(resource.getName(), resource);
				resource.addUser(user);
			}
		}

		return this;
	}

	public void function _removeUser(required component User){

		var User = arguments.user;
		var resources = this.getResources();

		if(!this.hasUser(User)){
			throw("Invalid call, this role does not have this user. Handle existence before trying to remove");
		} else {

			for(var Resource in resources){
				if(user.hasResource(resource.getName())){
					user.removeResource(resource.getName(), resource);
					resource.removeUser(User);
				}
			}

			variables.__removeUser(User);
		}
	}

	/**
	* When adding a resource to a role, we need to apply this resource to all user for this role
	*/
	public function addResource(required component resource){

		var resource = arguments.resource;
		var user = this.getUsers();

		if(isNull(variables.resources)){
			variables.resources = [];
		}

		arrayAppend(variables.resources,resource);
		entitySave(resource);

		if(this.hasUser()){
			for(var user IN user){
				if(!user.hasResource(resource.getName())){
					user.addResource(resource.getName(), resource);
					resource.addUser(user);
					entitySave(user);
					entitySave(resource);
				}
			}
		}

	}

}
