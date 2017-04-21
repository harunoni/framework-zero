/**
*
* @file  /C/websites/dev.letsflycheaper.com/auth/model/orm/tempLogins.cfc
* @author  Rory Laitila
* @description Represents a login which is temporary (only to be used once)
*
*/

component persistent="true" extends="login" discriminatorvalue="tempLogins" {

	property name="publicKey" column="logins_temp_public_key" hint="Used to send a one time use key to the user to access the temporary login for setting or resetting a password";

	public function setPublicKey(required string key){
		var saltedKey = new saltedHash("publictemplogin", arguments.key);
		variables.publicKey = saltedKey;
	}

}