/**
*
*
* @author  Rory Laitila	
* @description Controller
*
*/

component output="false" displayname=""  {

	public function init( fw ){
		variables.fw = arguments.fw;
		// writeDump(request.section);
		// writeDump(request.item);
		// abort;
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

		var CurrentUser = request.user;
		var Account = CurrentUser.getAccount();
		var userId = rc.users_id;
		var roleId = rc.id;


		if(CurrentUser.isSuper()){
			var Role = entityLoadByPK("roles", roleId);
			var User = entityLoadByPK("users", userId);

			transaction {
				Role.addUser(User);
				User.addRole(Role);
				ORMFlush();
				transaction action="commit";
			}
		}
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