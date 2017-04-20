/*
Author: Rory Laitila

*/

import auth.util.emailer.emailer;
import .zero.validations.*
component persistent="true" table="user" output="false" accessors="true" discriminatorColumn="user_extended_by"
{
	/* properties */

	property name="id" column="user_id" type="numeric" ormtype="int" fieldtype="id" generator="identity";
	property name="emailAddress" column="user_email" type="emailAddress" sqltype="varchar(255)" length="256" specTestValue="test@retailriver.com" unique="true" isExportSensitive="true" exportValue="testuser@raakaventures.com";
	property name="password" column="user_password" type="string" length="256" specTestValue="#HASH("test")#" serializeJson="false" isExportSensitive="true" exportValue="123456";
	property name="passwordSalt" column="user_salt" type="string" length="256" specTestValue="#HASH("salt")#" serializeJson="false" isExportSensitive="true" exportValue="123456";
	property name="firstName" column="user_first_name" length="255" sqltype="varchar(255)" specTestValue="John" isExportSensitive="true" exportValue="James";
	property name="lastName" column="user_last_name" length="255" sqltype="varchar(255)" specTestValue="Doe" isExportSensitive="true" exportValue="Doe";
	property name="type" column="user_type" length="45" specTestValue="User";
	property name="tempLogin" column="user_temp_login" length="128" specTestValue="#createUUID()#" serializeJson="false" isExportSensitive="true" exportValue="templogid";
	property name="tempLoginExpires" column="user_temp_login_expires" type="date" specTestValue="#now()#" serializeJson="false";
	property name="isDeleted" column="user_is_deleted" type="boolean" dbdefault="0" default="false";

	property name="account" fieldtype="many-to-one" cfc="accounts" fkcolumn="user_accounts_id";
	property name="roles" fieldtype="many-to-many" cfc="roles" linktable="user_roles" singularname="role" inverse="true";
	property name="resources" fieldtype="many-to-many" cfc="resources" linktable="resources_user" fkcolumn="user_id" type="struct" structkeycolumn="resources_name" notnull="true" singularname="resource" cascade="none" lazy="false";
	property name="logins" fieldtype="one-to-many" cfc="logins" fkcolumn="logins_user_id" singularname="login" cascade="all-delete-orphan";
	property name="email" fieldtype="one-to-many" cfc="email" fkcolumn="user_id" singularname="email";
	property name="auth" fieldtype="many-to-one" cfc="auth" fkcolumn="auth_id" inverse="true";


	public function getEmailAddress(){ return new emailAddress(variables.emailAddress); }
	public function getFirstName(){return new varchar255(variables.firstName?:"")}
	public function getLastName(){return new varchar255(variables.lastName?:"")}

	public function setEmailAddress(required emailAddress emailAddress){ variables.emailAddress = arguments.emailAddress.toString(); }
	public function setFirstName(required varchar255 firstName){variables.firstName = arguments.firstName.toString()}
	public function setLastName(required varchar255 lastName){variables.lastName = arguments.lastName.toString()}


	public function sendLogin(required component email)
	{
		var email = arguments.email;

		variables.password = "";
		//Create a login which is valid for 10 days to give the user enough time to access the site and set a password
		var loginCredentials = this.createTemporaryLogin();
		// this.setPasswordSalt("");
		// this.setTempLogin(CreateUUID());
		// this.setTempLoginExpires(dateAdd("d",1,now()));
		// this.save();
		ORMFlush();
		//Create emailer to send the details to
		// local.emailer = new emailer().sendSignupEmail(to=this.getEmailAddress(),
		// 											 tempLogin=this.getTempLogin(),
		// 											 firstName=this.getFirstName(),
		// 											 adminServer=this.getAccount().getAdminServer()
		// 											 );

		//Use the auth's default emails if one was not provided
		if(isNull(email.getSubject()) OR email.getSubject() IS "" ){
			email.setSubject("Thank you for signing up");
		}

		//Use the auth's default emails if one was not provided
		if(isNull(email.getTemplate()) OR email.getTemplate() IS "" ){
			email.setTemplate("signup");
		}

		email.setTo(this.getEmailAddress());

		email.sendEmail(
			data = {
			appName = this.getAccount().getName(),
			userToken = loginCredentials.token,
			passcode = loginCredentials.authentication,
			firstName = this.getFirstName(),
			adminServer = this.getAccount().getAdminServer()
		});

		email.setUser(this);
		entitySave(email);
		this.addEmail(email);
		entitySave(this);

	}

	public function setPassword(required password255 password)
	{
		variables.passwordSalt = CreateUUID();
		variables.password = hash(arguments.password.toString() & variables.passwordSalt,"SHA-256");
		this.setTempLogin("");
		return this;
	}

	public function checkPassword(required password255 password)
	{
		local.passwordHash = hash(arguments.password.toString() & variables.passwordSalt,"SHA-256");
		if(this.getPassword() IS local.passwordHash)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public function createTemporaryLogin(){
		return createLogin("tempLogins", 10);
	}

	/**
	* Creates a persistent login for the user that can be reused by subsequent requests
	*/
	public function createPersistentLogin(required numeric numberOfDays)
	{
		return createLogin(numberOfDays=arguments.numberOfDays);
	}

	/**
	* Creates a login of the appropriate type. There are two types of logins currently:
	* logins - The basic login type, used for browser logins
	* tempLogins - One time logins used for initial signups
	*/
	private function createLogin(loginType="logins", numberOfDays){
		local.login = entityNew(arguments.loginType);
		entitySave(local.login);
		local.userHash = local.login.setUserHash(variables.emailAddress).getUserHash();
		local.passcode = local.login.createNewLogin(arguments.numberOfDays);
		this.addLogin(local.login);
		local.login.setUser(this);
		return {authentication:local.passcode,token:local.userHash};
	}

	public boolean function isSuper(){
		return variables.type IS "super";
	}
}


