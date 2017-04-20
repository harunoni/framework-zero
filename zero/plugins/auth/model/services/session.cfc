/**
*
*
* @author  Rory Laitila
* @description Session Facade
*
*/

import auth.model.orm.ormUtil;

component output="false" displayname=""  {

	public function init(){
		return this;
	}

	/*
	* Accepts a User ORM object, logs in the user and sets the user data into the session scope
	*/
	public function loginUser(required component User)
	{

		session.isLoggedIn = true;
		session.user = arguments.user;
		session.userid = session.user.getId();
		session.userType = arguments.user.getType();
		session.account = user.getAccount();
		session.currentAccountName = user.getAccount().getName();
		session.adminPath = session.account.getAdminPath();
		session.accountPermissions = structKeyList(arguments.user.getAccount().getResources());
		session.permissions = structKeyList(arguments.user.getResources());

		//Get all account lists if this user is a super user so that we can switch from one account to the next
		if(session.userType IS "super")
		{
			session.permittedAccounts = entityToQuery(new ormUtil.load("accounts"));
		}

		return this;
	}

	public function getUsers(){
		return new ormUtil.load("user",session.userid,true);
	}

	/*
	* Accepts a User login ORM object and sets a persistent login on the user
	*/
	public function setPersistentLogin(required string auth, required string token, required string numberOfDays)
	{
		cookie expires="#arguments.numberOfDays#" name="auth" value="#arguments.auth#" httponly="true";
		cookie expires="#arguments.numberOfDays#" name="token" value="#arguments.token#" httponly="true";
	}

	public function checkPersistentLogin(required string auth, required string token)
	{
		local.login = new ormUtil.load("logins",{userHash=arguments.auth,passcode:hash(arguments.token,"SHA-256")},true);

		if(isObject(local.login))
		{
			local.expires = local.login.getExpireDate();

			if(dateCompare(local.expires,now()))
			{

				transaction {

					local.numberOfDays = local.login.getNumberOfDays();
					local.newToken = local.login.createNewLogin(local.numberOfDays);
					local.userHash = local.login.getUserHash();

					setPersistentLogin(auth=local.userHash,
									   token=local.newToken,
									   numberOfDays=local.numberOfDays);

					local.login.save();
					ORMFlush();
				}

				local.user = local.login.getUsers();
				loginUser(local.user);
				return true;
			}
		}
		return false;
	}


	public function hasPermission(required string resourceName, string adminPath)
	{
		if(
			session.userType IS "super" OR (session.accountPermissions CONTAINS arguments.resourceName AND session.permissions CONTAINS arguments.resourceName)
		  )
		{
			return true;
		}
		else
		{
			return false;
		}

	}

	public function checkAdminPath(required string adminPath)
	{
		if(session.userType IS NOT "super" AND arguments.adminPath IS NOT session.adminPath)
		{
			location url="#session.adminPath#" addtoken="false";
		}
	}

	public function logout(string auth, string token)
	{
		structClear(session);
		if(structKeyExists(arguments,"auth") AND structKeyExists(arguments,"token"))
		{
			expirePersistentAuth(arguments.auth, arguments.token);
		}
		session.isLoggedIn = false;

		return this;
	}

	private function expirePersistentAuth(required string auth, required string token)
	{

		local.login = new ormUtil.load("logins",{userHash=arguments.auth,passcode:hash(arguments.token,"SHA-256")},true);
		local.login.expireLogin();
		local.login.save();
		ORMFlush();
		setPersistentLogin(arguments.auth, arguments.token, 0);
	}


}