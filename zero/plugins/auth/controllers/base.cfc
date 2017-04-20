/**
*
* @author  Rory Laitila
* @description Handles some base functions of the API Calls
*
*/

component output="false" displayname="" accessors="true" extends="" {

	property name="error" hint="Determines whether an error was encountered" default="false";
	property name="errors" hint="Holds an array to the errors returned from the API" type="array";


	variables.error = false;
	variables.errors = [];

}