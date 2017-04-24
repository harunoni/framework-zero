/*
Author: Rory Laitila

*/

component persistent="true" table="roles" output="false" accessors="true" discriminatorColumn="roles_extended_by" discriminatorValue="role"
{
	/* properties */

	property name="id" column="roles_id" type="numeric" ormtype="int" fieldtype="id" generator="identity";
	property name="name" column="roles_name" type="string" specTestValue="test.*" sqltype="varchar(255)";
	property name="description" column="roles_description" type="string" specTestValue="Category Manager" sqltype="varchar(1024)";
	property name="type" column="roles_type" type="string" specTestValue="allow";

	property name="accounts" fieldtype="many-to-many" cfc="accounts" linktable="accounts_roles" singularname="account" inverse="true";
	property name="users" fieldtype="many-to-many" cfc="user" linktable="user_roles" singularname="user";
	property name="resources" fieldtype="many-to-many" cfc="resource" linktable="roles_resources" singularname="resource";
	property name="auth" fieldtype="many-to-one" cfc="auth" fkcolumn="auth_id" inverse="true";

	property name="availableResources" persistent="false" cfc="resource" setter="false";

	public function getName(){return new roleName(variables.name?:"")}
	public function getDescription(){return new roleDescription(variables.description?:"")}

	public function setName(required roleName name){ variables.name = arguments.name.toString();}
	public function setDescription(required roleDescription description){ variables.description = arguments.description.toString();}

	public function init(){

		//Swap methods that we are going to override to new private methods so that we can still use the ORM methods
		variables.__removeUser = this.removeUser;
		this.removeUser = variables._removeUser;

		variables.__addUser = this.addUser;
		this.addUser = variables._addUser;
	}

	/**
	* Looks at the permissions related to this role and ensures that the user has all of them
	*/
	public function _addUser(required component user){

		var user = arguments.user;
		var resources = this.getResources();

		user.addRole(this);

		//Add the user to the role which was the original intent of addUser() generated method
		variables.__addUser(user);

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
		var resources = this.getResources()?:[];

		if(!this.hasUser(User)){
			throw("Invalid call, this role does not have this user. Handle existence before trying to remove");
		} else {

			for(var Resource in resources){
				if(user.hasResource(resource.getName())){
					resource.removeUser(User);
					user.removeResource(resource.getName(), resource);
				}
			}

			variables.__removeUser(User);
			User.removeRole(this);
		}
	}

	/**
	* When adding a resource to a role, we need to apply this resource to all user for this role
	*/
	public function addResource(required component resource){
		// writeDump(callStackGet());
		// abort;
		var resource = arguments.resource;
		var user = this.getUsers();
		// writeDump(user);
		if(isNull(variables.resources)){
			variables.resources = [];
		}

		if(!this.hasResource(resource)){
			arrayAppend(variables.resources,resource);
			entitySave(resource);
		}

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

	public function getAvailableResources(){

		var allResources = this.getAuth().getRootResources();
		var unassigned = [];
		for(var Resource in allResources){
			if(!this.hasResource(Resource)){
				unassigned.append(Resource);
			}
		}
		return unassigned;
	}

}
