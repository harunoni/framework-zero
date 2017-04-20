/**
*
* @author  Rory Laitila
* @description Basic configuration for the auth module
*
*/

component output="false" displayname=""  {

	public function init(){
		return this;
	}

	public function getMenuTransformations(){
		return [
			{
				key:"portal.auth.accounts.edit",
				type:"rename",
				value:"Create New"
			}
		];
	}
}