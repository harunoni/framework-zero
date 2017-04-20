/**
*
* @author  Rory Laitila
* @description Factory for ORM (active records) objects.
*
*/

component  {

	public function init(){
		return this;
	}

	public function getService(required serviceName)
	{
		return createObject("component",arguments.serviceName);
	}

	public function create(string entityName, struct properties={}){
		var result = entityNew(arguments.entityName,arguments.properties);
		return result;
	}

	public function flush(){
		ORMFlush();
	}

	public function save(required entity){
		entitySave(arguments.entity);
	}

	public function Load(string EntityName, filterCriteria={}, unique=false, sortOrder=""){
		

		if(arguments.sortOrder IS NOT "" AND arguments.unique)
		{
			throw("You can not define a sort order while expecting a unique return");
		}

		var result = entityLoad(entityName,filterCriteria,arguments.sortOrder);
		if(NOT isDefined("result"))
		{
			return [];
		}
		else{
			if(arguments.unique AND result.len() GT 1)
			{
				throw("Expected a unique entity but returned multiple");
			}
			else if(arguments.unique AND result.len() IS 0)			
			{
				return [];
			}
			else if(arguments.unique)
			{
				return result[1];
			}
			else{
				return result;
			}
		}

		return result;
	}

	public function createOrLoad(string EntityName, struct filterCriteria, unique=false){
		
		var tryLoad = load(argumentCollection=arguments);

		if(arguments.unique AND isObject(tryLoad))
		{
			return tryLoad;
		}
		else if(tryLoad.len() IS 0)
		{
			var entity = this.create(entityName);
			entity.populate(arguments.filterCriteria);
			/*metaData = getMetaData(entity);
			properties = getArraysByStructKey(metaData.properties,"name");
			
			for(name in filterCriteria)
			{
				if(structKeyExists(properties[name],"insert"))
				{
					
				}
				else
				{
					evaluate("entity.set#name#(""#filterCriteria[name]#"")");
				}
				
			}*/
			
			return entity;
		} else {
			return tryLoad;
		}
	}
	
}