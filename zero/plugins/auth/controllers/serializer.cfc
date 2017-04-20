/**
*
* @file  /C/websites/portal.itr8group.com/auth/controllers/serializer.cfc
* @author
* @description test
*
*/

component output="false" displayname="" extends="zero.serializer"  {

	public function getAccount(required account, includes="user"){
		local.out = {
			"id":account.getId(),
			"name":account.getName(),
			"address":account.getAddress(),
			"type":account.getType(),
			"status":account.getStatus(),
			"admin_path":account.getAdminPath(),
		}

		if(includes.contains("user")){local.out["user"].getUsers(account.getUsers())}
		return;
	}

	public function getAccounts(required array accounts){
		local.out = [];
		arguments.accounts.each(function(account){
			out.append(getAccount(account));
		});
		return local.out;
	}

	public function getResource(required resource){
		return {
			"name":resource.getName(),
		}
	}

	public function getResources(required array Resources){
		local.out = [];
		arguments.resources.each(function(resource){
			out.append(getResource(Resource));
		});
		return local.out;
	}

	public function serializeCustomFields(required array fields){

		var fields = arguments.fields;
		var fieldsOut = [];

		for(var field IN fields){
			fieldsOut.append({"name":field.name, "field":camelToUnderscore(field.name), "type":field.type});
		}

		return fieldsOut;
	}

}