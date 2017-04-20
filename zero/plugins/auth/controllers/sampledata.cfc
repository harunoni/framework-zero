/**
*
* @file  /C/websites/portal.itr8group.com/home/controllers/apps.cfc
* @author  Rory Laitila	
* @description Controller to import sample data
*
*/

import auth.model.orm.ormUtil;

component output="false" displayname=""  {

	public function init( fw ){
		variables.fw = arguments.fw
		return this;
	}

	public function default( rc ){


		var account = new ormUtil().createOrLoad("accounts",{name:"Letsflycheaper"}, true);
		account.save();

		

		var testUsers = [
			{
				firstName:"Saas Admin",
				email:"sassadmin@itr8group.com"
			},
			{
				firstName:"Agency Admin",
				email:"agencyadmin@itr8group.com"
			},
			{
				firstName:"Booking Agent",
				email:"bookingagent@itr8group.com"
			},
			{
				firstName:"Ticketing Agent",
				email:"ticketingagent@itr8group.com"
			},
			{
				firstName:"Customer",
				email:"customer@itr8group.com"
			}
		];

		var roles = [
			{
				name:"Saas Admin",
				resources:[
					{name:"portal.letsflycheaper"},
					{name:"portal.letsflycheaper_public"}

				]
			},
			{
				name:"Agency Admin",
				resources:[
					{name:"portal.letsflycheaper"},
				]
			},
			{
				name:"Booking Agent",
				resources:[
					{name:"portal.letsflycheaper"},
				]
			},
			{
				name:"Ticketing Agent",
				resources:[
					{name:"portal.letsflycheaper"},
				]
			},
			{
				name:"Customer",
				resources:[
					{name:"portal.letsflycheaper_public"},
				]
			}
		];

		for(var role IN roles){
			var roleEntity = new ormUtil().createOrLoad("roles",{name:role.name}, true);

			if(!account.hasRole(roleEntity)){
				account.addRole(roleEntity);
				roleEntity.addAccount(account);				
			}

			entitySave(account);
			entitySave(roleEntity);

			for(var resource IN role.resources){
				var resourceEntity = new ormUtil().createOrLoad("resources", {name:resource.name}, true);
				entitySave(resourceEntity);
				//writeDump(roleEntity.getResources());
				//abort;

				roleEntity.addResource(resourceEntity);
				resourceEntity.addRole(roleEntity);	


				entitySave(resourceEntity);
				entitySave(roleEntity);
				ORMFlush();
				/* writeDump(roleEntity);
				abort; */
			}

		}

		for(var user IN testUsers){
			var userEntity = new ormUtil().createOrLoad("users", {firstName:user.firstName, email:user.email},true);
			entitySave(userEntity);

			var roleEntity = new ormUtil().createOrLoad("roles",{name:user.firstName}, true);

			if(!roleEntity.hasUser(userEntity)){
				roleEntity.addUser(userEntity);
				userEntity.addRole(roleEntity);
				entitySave(roleEntity);
				entitySave(userEntity);				
			}

		}
		ORMFlush();
		writeDump(now());
		abort;


	}

	public function new( rc ){

	}

	public function create( rc ){

	}

	public function show( rc ){

	}

	public function update( rc ){

	}

	public function destroy( rc ){
		
	}
}