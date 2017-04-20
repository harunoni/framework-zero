/**
*
* @file  /C/websites/rory.itr8group.com/auth/model/orm/extendedEntityMetaData.cfc
* @author  Rory Laitila
* @description supports comparing an entity that extends a parent to determine what are the unique fields in the entity.
*
*/

import auth.util.portalcommon.util.entityMetaData;

component output="false" displayname=""  {

	public function init(required entity){

		if(isObject(arguments.entity)){
			variables.entity = arguments.entity;			
		} else {
			variables.entity = entityNew(arguments.entity);
		}

		variables.entityMetaData = new entityMetaData(variables.entity);
		return this;
	}

	public array function getChildEntityNames(){
		var ormMetaData = getORMClassMetaData();
    	var currentEntityORMMetaData = getEntityORMMetaData();       	

       	var extendedEntities = [];

	    if(currentEntityORMMetaData.hasSubclasses()){
	   		
	   		for(var class in ormMetaData){       			
	   			var mappedSuperClass = ormMetaData[class].getMappedSuperClass();
	   			if(!isNull(mappedSuperClass)){
	   				if(mappedSuperClass IS variables.entityMetaData.getEntityName()){
	   					extendedEntities.append(class);
	   				}
	   			}
	   		}
	    }

	    return extendedEntities;
	}

	public array function getFields(){
		if(hasParent()){
			fields = new entityMetaData(variables.entity).getFields();			
		} else {
			fields = [];
		}
		return fields;
	}

	private boolean function hasParent(){

		if(isNull(getEntityORMMetaData().getMappedSuperClass())){
			return false;
		} else {
			return true;
		}

	}

	private component function getParentEntity(){
		var entityName = getEntityORMMetaData().getMappedSuperClass();
		return entityNew(entityName);
	}

	private object function getEntityORMMetaData(){
		var ormMetaData = getORMClassMetaData();
    	return currentEntityORMMetaData = ormMetaData[variables.entityMetaData.getEntityName()];   
	}

	private struct function getORMClassMetaData(){
		return ORMGetSessionFactory().getAllClassMetaData();
	}

	
}