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
		// writeDump(Role);
		// abort;
		var out = {
			"success":true,
			"message":"The role was successfully loaded",
			"data":{
				"role":variables.fw.serialize(Role, {
					resources:{},
					availableResources:{
						"@recurse":{
							children:{}
						}
					}
				}),
			}
		}
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

	public function destroy( rc ){

		var CurrentUser = request.user;
		var Account = CurrentUser.getAccount();
		var userId = rc.users_id;
		var roleId = rc.id;

		if(CurrentUser.isSuper()){
			var Role = entityLoadByPK("roles", roleId);
			var User = entityLoadByPK("users", userId);

			if(!Role.hasUser(User)){
				throw("This user did not have this role");
			} else {
				transaction {
					Role.removeUser(User);
					User.removeRole(Role);
					ORMFlush();
					transaction action="commit";
				}
			}
		}
	}
}