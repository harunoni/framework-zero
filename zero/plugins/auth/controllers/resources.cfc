/**
*
* @file  /C/websites/portal.itr8group.com/home/controllers/apps.cfc
* @author  Rory Laitila
* @description Controller
*
*/

component output="false" displayname="" nested="users" {

	public function init( fw ){
		variables.fw = arguments.fw;
		return this;
	}

	public struct function list( ){

		var ZeroAuth = variables.fw.getZeroAuth();
		var Resources = ZeroAuth.getResources();
		var resourcesTable = new zerotables.resources.table();

		var out = {
			"success":true,
			"message":"The resources were successfully loaded",
			"data":{
				"resources":resourcesTable.toJson()
			}

		}
		return out;
	}

	public struct function link(numeric roles_id, numeric id){

		var ZeroAuth = variables.fw.getZeroAuth();
		var Resource = ZeroAuth.findResourceById(arguments.id).elseThrow("Could not load that resource");

		if(arguments.keyExists("roles_id")){
			var Role = ZeroAuth.findRoleById(arguments.roles_id).elseThrow("Could not load that resource");
			Role.addResource(Resource);
			transaction {
				ORMFlush();
				transaction action="commit";
			}

			var out = {
				"success":true,
				"message":"The resource has been successfully added to the role",
			}
			return out;
		}
	}

	public struct function unlink(numeric roles_id, numeric id){

		var ZeroAuth = variables.fw.getZeroAuth();
		var Resource = ZeroAuth.findResourceById(arguments.id).elseThrow("Could not load that resource");

		if(arguments.keyExists("roles_id")){
			var Role = ZeroAuth.findRoleById(arguments.roles_id).elseThrow("Could not load that resource");
			Role.removeResource(Resource);
			transaction {
				ORMFlush();
				transaction action="commit";
			}

			var out = {
				"success":true,
				"message":"The resource has been successfully removed from the role",
			}
			return out;
		}
	}


	public function new( rc ){

	}

	public function create( rc ){

	}

	public function show( rc ){

	}

	public function update( rc ){

	}

	public function destroy( rc ){

		param name="rc.id";


		var resource = entityLoad("resources", {id:rc.id}, true);
		transaction {
			if(isNull(resource)){
				throw("Error loading resource");
				transaction action="rollback";
			} else {
				if(requestHasUser(rc)){
					var user = loadUserFromRC(rc);
					if(isNull(user)){
						throw("User now found");
					} else {
						resource.removeUser(user);
						ORMFlush();
						rc.data = {
							"success":"true",
							"message":"The resource has been removed from the user"
						}
					}
				}
			}
		}
		abort;
	}

	private function requestHasUser(required struct rc){
		return structKeyExists(arguments.rc, "users_id");
	}

	private function loadUserFromRC(required struct rc){
		return entityLoad("users", arguments.rc.users_id, true);
	}


}