import auth.model.orm.ormUtil;
import auth.util.querystring.querystring;
import auth.model.orm.extendedEntityMetaData;
import auth.util.portalcommon.util.entityMetaData;

component accessors="true" extends="base" {
	
	public any function init( fw ) {
		variables.fw = fw;
		
		return this;
	}

	public void function before( rc ) {
		variables.auth = entityLoadByPK("auth", 1);
	}
	
	public void function default( rc ) {
       //entityLoad("users");
       variables.fw.setView('accounts.list');
       rc.accounts = variables.auth.getAccounts();
       rc.data.accounts = new serializer().serializeEntity(rc.accounts);

       var extendedEntityNames = variables.auth.getExtendedAccountTypes();       
       rc.data.extendedEntities = ["accounts"].merge(extendedEntityNames);

	}

	public function destroy(rc){
		param name="rc.id";		
		rc.account = entityLoad("accounts",rc.id,true);
		if(!isNull(rc.account))
		{
			entityDelete(rc.account);
			ORMFlush();
			rc.data.message = "The account has been successfully deleted";
			if(structKeyExists(rc,"goto"))
			{
				location url="#rc.goto#?message=#rc.data.message#" addtoken="false";
			}
		}
	}

	public function create(){

		param name="rc.id" default="0";
		variables.fw.setView('accounts.new');
				
		rc.account = variables.auth.newAccount(rc.entityType);

		var validFields = "address,admin_path,admin_server,name,type";
		rc.customFields = new extendedEntityMetaData(rc.account).getFields();
		rc.data.customFields = new serializer().serializeCustomFields(rc.customFields);

		for(var field IN rc.data.customFields){
			validFields = validFields.listAppend(field.field);
		}

		validateFieldsExist(validFields,rc);
		rc.fields = getValidKeysAsStruct(validFields,rc);

		rc.account.populate(rc.fields);
		setPermissions(rc);
		entitySave(rc.account);
		ORMFlush();
		location url="/auth/accounts/#rc.account.getId()#" addtoken="false";

		// rc.data.account = new serializer().serializeEntity(rc.data.account, "users,resources");		
		// rc.resources = entityLoad("resources");
	}

	public function new(){
		rc.id = 0;
		param name="rc.entityType" default="accounts";
		
		variables.fw.setView('accounts.new');
		rc.account = new ormUtil().createOrLoad(rc.entityType,{id=rc.id});

		rc.data.account = new serializer().serializeEntity(rc.account, "users,resources");
		rc.customFields = new extendedEntityMetaData(rc.account).getFields();
		rc.data.customFields = new serializer().serializeCustomFields(rc.customFields);
		rc.data.entityType = rc.entityType;
		rc.resources = entityLoad("resources");

	}
	
	public void function show( rc ){
		param name="rc.id" default="0";
		param name="rc.resourceids" default="#[]#";
		variables.fw.setView('accounts.new');
		rc.account = new ormUtil().createOrLoad("accounts",{id=rc.id}, true);
		rc.data.account = new serializer().serializeEntity(rc.account, "users,resources");	
		rc.customFields = new extendedEntityMetaData(rc.account).getFields();
		rc.data.customFields = new serializer().serializeCustomFields(rc.customFields);
		rc.data.entityType = new entityMetaData(rc.account).getEntityName();
		rc.resources = variables.auth.getResources();
	}

	public function update(){

		variables.fw.setView('accounts.new');

		rc.account = new ormUtil().createOrLoad("accounts",{id=rc.id},true);		

		var validFields = "address,admin_path,admin_server,name,type";
		rc.customFields = new extendedEntityMetaData(rc.account).getFields();
		rc.data.customFields = new serializer().serializeCustomFields(rc.customFields);

		for(var field IN rc.data.customFields){
			validFields = validFields.listAppend(field.field);
		}

		validateFieldsExist(validFields,rc);
		rc.fields = getValidKeysAsStruct(validFields,rc);

		rc.account.populate(rc.fields);
		
		rc.account.save();		
		setPermissions(rc);
		
		rc.data.account = new serializer().serializeEntity(rc.account, "users,resources");
		
		rc.data.entityType = new entityMetaData(rc.account).getEntityName();		

		rc.resources = entityLoad("resources");
		ORMFlush();	
		rc.id = rc.account.getId();	


		//location url="/?action=auth:accounts.edit&id=#rc.id#";
		
	}

	private function setPermissions(rc){
		//For each resource on the form
		if(structKeyExists(rc,"resourceids"))
		{
			for(local.resourceId in rc.resourceids)
			{
				local.resourceEnabled = rc.resourceids[local.resourceid];
				//Get the resource name from the hidden field, this makes it easy to loop through
				local.resourceName = lcase(rc.resourcenames[local.resourceid]);
				
				//If the resource is set to 0, that means it should be off. We first need to check if the user has this resource
				if(local.resourceEnabled IS 0)
				{
					//If the use has the resource, then it needs to be removed
					if(rc.account.hasResource(local.resourceName))
					{
						rc.account.removeResource(local.resourceName);
					}
				}
				else //If the resource needs to be enabled
				{
					//check if the user does not yet have the resource
					if(NOT rc.account.hasResource(local.resourceName))
					{
						//If they do not, load the resource so that we can add it to the account
						local.resource = entityLoad("resources",local.resourceId,true);

						rc.account.addResource(local.resourceName,local.resource);
						local.resource.addAccount(rc.account);
						rc.account.save();
						local.resource.save();
						
					}
				}
			}
		}		
	}
	
}
