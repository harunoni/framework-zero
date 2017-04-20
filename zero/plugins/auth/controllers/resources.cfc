/**
*
* @file  /C/websites/portal.itr8group.com/home/controllers/apps.cfc
* @author  Rory Laitila	
* @description Controller
*
*/

component output="false" displayname=""  {

	public function init( fw ){
		variables.fw = arguments.fw;		
		return this;
	}

	public function default( rc ){

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