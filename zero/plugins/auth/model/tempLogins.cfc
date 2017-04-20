/**
*
* @file  /C/websites/dev.letsflycheaper.com/auth/model/orm/tempLogins.cfc
* @author  Rory Laitila
* @description Represents a login which is temporary (only to be used once)
*
*/

component persistent="true" extends="logins" discriminatorvalue="tempLogins" {
	
}