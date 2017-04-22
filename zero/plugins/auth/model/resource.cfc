/*
Author: Rory Laitila

*/

component persistent="true" table="resources" output="false" accessors="true" discriminatorColumn="resources_extended_by" discriminatorValue="base"
{
	/* properties */

	property name="id" column="resources_id" type="numeric" ormtype="int" fieldtype="id" generator="identity";
	property name="name" column="resources_name" type="string" specTestValue="test.*";
	property name="description" column="resources_description" type="string" specTestValue="Category Manager";
	property name="type" column="resources_type" type="string" specTestValue="allow";

	property name="parent" fieldtype="many-to-one" cfc="resource" fkcolumn="resources_parent_id";
	property name="children" fieldtype="one-to-many" cfc="resource" fkcolumn="resources_parent_id" singularname="child" inverse="true";

	property name="users" fieldtype="many-to-many" cfc="user" linktable="resources_user" fkcolumn="permissions_resources_id" singularname="user" inverse="true";
	property name="accounts" fieldtype="many-to-many" cfc="accounts" linktable="resources_accounts" fkcolumn="permissions_resources_id" singularname="account" inverse="true";
	property name="roles" fieldtype="many-to-many" cfc="role" linktable="roles_resources" singularname="role" inverse="true";
	property name="auth" fieldtype="many-to-one" cfc="auth" fkcolumn="auth_id" inverse="true";

	/**
	* Override addUser function so that we can recursively add the resources for all child resources and all parent resources
	*/

	public function init(){

		//Swap methods that we are going to override to new private methods so that we can still use the ORM methods
		variables.__addUser = this.addUser;
		variables.__removeUser = this.removeUser;

		this.addUser = variables._addUser;
		this.removeUser = variables._removeUser;

	}

	public function _addUser(required component user){

		var user = arguments.user;

		recurseAddChildren(user, this);
		recurseAddParents(user, this);
		variables.__addUser(User);
		User.addResource(this.getName(), this);

		entitySave(user);
		entitySave(this);
		return this;
	}

	public function _removeUser(required component user){
		var user = arguments.user;

		recurseRemoveChildren(user, this);
		__removeUser(user);

		entitySave(user);
		entitySave(this);

		return this;
	}

	private function recurseRemoveChildren(required component user, required component resource){
		var resource = arguments.resource;
		var user = arguments.user;

		if(resource.hasChild()){

			var children = resource.getChildren();

			for(var child IN children){
				recurseRemoveChildren(user, child);
			}
		}

		user.removeResource(resource.getName(), resource);
	}

	/**
	* Recursively adds all child resources to the user, because if we are adding a resource, we assume that all children are valid too
	*/
	private void function recurseAddChildren(required component user, required component resource){

		var resource = arguments.resource;
		var user = arguments.user;

		if(resource.hasChild()){

			var children = resource.getChildren();
			for(var child IN children){

				if(!user.hasResource(child.getName())){
					user.addResource(child.getName(), child);
					child.addUser(user);
				}

				recurseAddChildren(user, child);

			}

		}

	}

	/**
	* Recursively adds parents of the resource to the user, since in order to reach this child resource, they will
	* need permission of the parent also.
	*/
	private void function recurseAddParents(required component user, required component resource){

		var user = arguments.user;
		var resource = arguments.resource;

		if(resource.hasParent()){

			var parent = resource.getParent();

			if(!user.hasResource(parent.getName())){
				user.addResource(parent.getName(), parent);
				parent.addUser(user);
			}

			recurseAddParents(user, parent);

		}

	}
}
