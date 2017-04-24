/**
*
*
* @author  Rory Laitila
* @description Controller
*
*/

component output="false" displayname="" nested="resources,users"  {

	public function init( fw ){
		variables.fw = arguments.fw;
		// writeDump(request.section);
		// writeDump(request.item);
		// abort;
		return this;
	}

	public function list(){

		var ZeroAuth = variables.fw.getZeroAuth();
		var Roles = ZeroAuth.getRoles();
		var rolesTable = new zerotables.roles.table();

		var out = {
			"success":true,
			"message":"The roles were successfully loaded",
			"data":{
				"roles":rolesTable.toJson()
			}

		}
		return out;
	}

	public struct function new(){

		var out = {
			"success":true
		}
		return out;
	}

	public function create(required roleName name, required roleDescription description){

		var ZeroAuth = variables.fw.getZeroAuth();
		transaction {
			var Role = ZeroAuth.createOrLoadRole(name=arguments.name, description=arguments.description);
			ORMFlush();
			transaction action="commit";
		}

		var out = {
			"success":true,
			"message":"The role was successfully created or loaded",
			"data":{
				"role":variables.fw.serialize(Role)
			}
		}
		return out;
	}

	public function read( id ){

		var ZeroAuth = variables.fw.getZeroAuth();
		var Role = ZeroAuth.findRoleById(arguments.id).elseThrow("Could not locate that role");
		var allResources = ZeroAuth.getRootResources();
		// abort;
		var out = {
			"success":true,
			"message":"The role was successfully loaded",
			"data":{
				"role":variables.fw.serialize(Role, {
					resources:{},
					users:{},
					availableResources:{
						"@recurse":{
							children:{}
						}
					}
				}),
				"all_resources":variables.fw.serialize(allResources, {
					"@recurse":{
						children:{}
					}
				}),
			}
		}

		var recurseAddEnabledFlag = function(availableResources, existingResources, parent){
			var availableResources = arguments.availableResources;
			var existingResources = arguments.existingResources;

			for(var resource in availableResources){

				resource.is_disabled = false;
				resource.is_enabled = false;

				if(arguments.keyExists("parent")){

					if(parent["is_enabled"] == true or parent.is_disabled == true){
						resource.is_disabled = true;
					} else {
						resource.is_disabled = false;
					}
				}

				for(var existingResource in existingResources){
					if(existingResource.name == resource.name){
						resource["is_enabled"] = true;
						break;
					}
				}

				if(arrayLen(resource.children) GT 0){
					recurseAddEnabledFlag(resource.children, existingResources, resource);
				}
			}
		}
		// writeDump(out);
		// abort;
		recurseAddEnabledFlag(out.data.all_resources, out.data.role.resources);
		return out;
	}

	public function update( required id, roleName name, roleDescription description){

		var ZeroAuth = variables.fw.getZeroAuth();
		var Role = ZeroAuth.findRoleById(arguments.id).elseThrow("Could not locate that role");
		arguments.role = Role;
		transaction {
			ZeroAuth.updateRole(argumentCollection=arguments);
			ORMFlush();
			transaction action="commit";
		}
		var out = {
			"success":true,
			"message":"The role was successfully updated",
			"data":{
				"role":variables.fw.serialize(Role)
			}
		}
		return out;
	}

	public function delete(id){

		var ZeroAuth = variables.fw.getZeroAuth();
		var Role = ZeroAuth.findRoleById(arguments.id).elseThrow("Could not locate that role");
		transaction {
			ZeroAuth.deleteRole(Role);
			ORMFlush();
			transaction action="commit";
		}
		var out = {
			"success":true,
			"message":"The role has been successfully deleted"
		}
		return out;
	}
}