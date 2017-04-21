/**
*
*
* @author  Rory Laitila
* @description ORM component for Logins which controlls persistent login connections for each user
*
*/

component output="false" table="logins" displayname="" persistent="true" discriminatorColumn="logins_extended_by"{

	property name="id" column="logins_id" type="numeric" ormtype="int" fieldtype="id" generator="identity";
	property name="userHash" column="logins_user_hash" type="string" length="128" specTestValue="#HASH(createUUID())#" isExportSensitive="true" exportValue="123456";
	property name="passcode" column="logins_passcode" type="string" length="128" specTestValue="#HASH(createUUID())#" isExportSensitive="true" exportValue="123456";
	property name="expireDate" column="logins_expire_date" type="datetime" specTestValue="#createODBCDateTime(now())#";
	property name="createdDate" column="logins_created_date" type="datetime" specTestValue="#createODBCDateTime(now())#";

	property name="user" fieldtype="many-to-one" cfc="user" fkcolumn="logins_user_id" inverse="true";

	public function init(){
		return this;
	}

	public function expireLogin()
	{
		variables.expireDate = createODBCDateTime(now());
	}

	private function setExpireDateDays(required numeric numberOfDays)
	{
		variables.expireDate = createODBCDateTime(dateAdd("d",arguments.numberOfDays,now()));
	}

	public function createNewLogin(required numeric numberOfDays)
	{
		local.passcode = replace(createUUID(),"-","","all");
		setExpireDateDays(arguments.numberOfDays);
		setCreatedDate(createODBCDateTime(now()));
		setPasscode(new saltedHash(variables.userHash, local.passcode));
		return local.passcode;
	}

	public function setUserHash(required string userName)
	{
		variables.userHash = hash(arguments.userName,"SHA-256");
		return this;
	}

	public function getUserHash()
	{
		return variables.userHash;
	}

	public function getNumberOfDays()
	{
		return dateDiff("d",getCreatedDate(),getExpireDate());
	}

	public boolean function checkPasscode(required string authentication){
		var checkPasscode = new saltedHash(variables.userHash, arguments.authentication);
		return 	checkPasscode == variables.passcode;
	}




}