/**
*
* @file  /C/websites/dev.letsflycheaper.com/auth/model/orm/saltedHash.cfc
* @author  Rory Laitila
* @description represents a saltedHash for user logins
*
*/

component persistent="false" {

	public function init(required string salt, required string password){
		return hash(arguments.salt & arguments.password,"SHA-256");		
	}
}