<cfcomponent output="true" accessors="true">
	<!--- <cffunction name="populate" hint="populates the entity with the records passed in">
		<cfargument name="fields">
		
		<cfset variables.meta = getMetaData(this)>
		
		<!--- ORM has what I consider to be a bug where on a new ORM object, the variables do not really exist, although you 
		can see them if you dump the object. As such I manually create them and set an empty value --->	
		<cfloop array="#variables.meta.properties#" index="i">
			<cfif NOT structKeyExists(variables,i.name) AND i.name IS NOT "id" AND NOT structKeyExists(i,"cfc")>
				<cfif structKeyExists(i,"default")>
					<cfset variables[i.name] = i.default>
				<cfelse>
					<cfset variables[i.name] = "">
				</cfif>				
			</cfif>
		</cfloop>

		<cftry>
			<cflog file="portal" text="Try loops" />
			<cfloop collection="#arguments.fields#" item="key">
				<cfif structKeyExists(variables,key) AND structKeyExists(this,"set#key#")>
					<cflog file="portal" text="this.set#key#(arguments.fields[key])" />
					<cfset evaluate("this.set#key#(arguments.fields[key])")>
				</cfif> 			
			</cfloop>
		<cfcatch type="any">
			
			<cfdump var="#arguments.fields#" />
			<cfdump var="#cfcatch#" abort="true"/>
		</cfcatch>
			
		</cftry>
		<!--- Now we can actually populate the object --->
		
		<cfreturn this>
	</cffunction> --->

	<cfscript>
		public function populate(fields)
		{
			
			variables.meta = getMetaData(this);

			var allProperties = variables.meta.properties;
			//allProperties.merge(variables.meta.properties);

			if(structKeyExists(variables.meta,"extends")){
				var parent.meta = getComponentMetaData(variables.meta.extends.fullName);
				
				allProperties = allProperties.merge(parent.meta.properties);
				
			}

					
			/* ORM has what I consider to be a bug where on a new ORM object, the variables do not really exist, although you 
			can see them if you dump the object. As such I manually create them and set an empty value */
			loop array="#allProperties#" index="i"
			{
			
				if( NOT structKeyExists(variables,i.name) AND i.name IS NOT "id" AND NOT structKeyExists(i,"cfc"))
				{
					if(structKeyExists(i,"default"))
					{
						variables[i.name] = i.default;
					}
					else{
						variables[i.name] = "";
					}
					
				}
			}
			
			// Now we can actually populate the object
			loop collection="#arguments.fields#" item="key"
			{
				if (structKeyExists(variables,key) AND structKeyExists(this,"set#key#"))
				{
					evaluate("this.set#key#(arguments.fields[key])");
				}
			}
			
			return this;
		}
	</cfscript>
	
	<cffunction name="save">
		<cfset EntitySave(this)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="delete">
		<cfset EntityDelete(this)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="reload">
		<cfreturn entityReload(this)>
	</cffunction>

	<cfscript>
		
	</cfscript>
	
	<cffunction name="getPropertyValue">
		<cfargument name="propertyName">
		<cfreturn variables[arguments.propertyName]>	
	</cffunction>
	
	<cffunction name="test">
		<cfargument name="name">
		<cfset variables.NAME = arguments.name>
	</cffunction>

	<cfscript>
		public function create(string entityName, struct properties={}){
		var result = entityNew(arguments.entityName,arguments.properties);
		return result;
	}

	public function flush(){
		ORMFlush();
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
		}
	}
	</cfscript>
	
	<cffunction name="createFormItems" hint="Uses the ORM components properties to dynamically build out form fields">
		<cfscript>
			//Get the meta data of this object
			meta = getMetaData(this);
			//Get the properties
			properties = meta.properties;
			
			//A structure that will contian all of the form items for this object
			var formItems = [];
			var workingStruct = {};
			var property = "";
			/* Loop through each property and determine if it should be available as a form element
			Forms will need the following properties
			
			type
			value
											
			
			*/
			for (i=1;i LTE arrayLen(properties); i=i+1)
			{
				workingStruct = {};
				property = properties[i];
				
				//Set defaults which will be overwritten
				workingStruct.disabled = "";
				workingStruct.type = "text";
				workingStruct.name = property.name;
				if(NOT structKeyExists(variables,property.name))
				{
					workingStruct.value = "";
				}
				else
				{
					workingStruct.value = variables[property.name];		
				}
					
				 
				
				
				//If the default type is string or Numeric
				if(structKeyExists(property,"type") AND (property.type IS "string" OR property.type IS "numeric"))
				{
					structInsert(workingStruct,"type","text",true);
				}
				
				//If the default type is id then it should not be enabled
				if(structKeyExists(property,"fieldtype") AND (property.fieldtype IS "id"))
				{
					structInsert(workingStruct,"disabled","disabled="" """,true);
				}
				
				//If the default type is boolean
				if(structKeyExists(property,"type") AND (property.type IS "boolean"))
				{
					structInsert(workingStruct,"type","checkbox",true);
				}
				
				
				
				
				//If the fieldtype is a relationship, then we don't want to set a value 
				if(structKeyExists(property,"fieldtype") AND (property.fieldtype IS "one-to-one" OR property.fieldtype IS "one-to-many"))
				{
					//value = 1;
					writeDump(isDefined("this.has#property.name#"));
					writeDump(evaluate("has#property.name#()"));
					if(isDefined("this.has#property.name#") AND evaluate("has#property.name#()"))
					{
						value = property.name & " ID: " & variables[property.name].getId();
					}
					else
					{
						value = "none";
					}
					
					
					structInsert(workingStruct,"value",value,true);
					structInsert(workingStruct,"disabled","disabled="" """,true);
				}
				
				ArrayAppend(formItems,workingStruct);
				
			}
			variables.formItems = local.formItems;
		</cfscript>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getFormItems">
		<cfreturn variables.formItems>
	</cffunction>
	
	<cffunction name="getPropertyKey" hint="Gets the value of a property. Typically used for forms">
		<cfargument name="formElement" required="true">
		<cfargument name="propertyName" required="true">
	    <cfscript>
	    	var meta = getMetaData(this);
	    	propertyKeys = structFindValue(meta,arguments.propertyName)[1].owner;
	    	
	    	if(structKeyExists(propertyKeys,arguments.formElement))
	    	{
	    		return structFind(propertyKeys,arguments.formElement);
	    	}
	    	else
	    	{
	    		return "";
	    	}
	    	
	    </cfscript>
	</cffunction>
	
	<cffunction name="getFormValue">
		<cfargument name="formElement" required="true">
		<cfargument name="propertyName" required="true">
	</cffunction>
	
	<cffunction name="asQuery" returnType="query">
		<cfreturn EntityToQuery(variables.result)>
	</cffunction>
	
	<cffunction name="getAsStruct">
		<cfset var meta = getMetaData(this)>
		<cfset returnStruct = {}>
		<cfloop from="1" to="#arrayLen(meta.properties)#" index="i">
			<cfif NOT StructKeyExists(meta.properties[i], 'fieldtype')>
				<cfinvoke component="#this#" method="get#meta.properties[i].name#" returnVariable="value" />
				<cfif isNull(value)>
					<cfset value = "">
				</cfif>
				<cfset returnStruct[meta.properties[i].name] = value>
			<cfelseif meta.properties[i].fieldtype CONTAINS 'column' OR meta.properties[i].fieldtype CONTAINS 'id'>
				
				<cfinvoke component="#this#" method="get#meta.properties[i].name#" returnVariable="value" />
				<cfif isNull(value)>
					<cfset value = "">
				</cfif>
				
				<cfset returnStruct[meta.properties[i].name] = value>
			<cfelse>
			
			</cfif>
		
		</cfloop>
		
		<cfreturn returnStruct>
	</cffunction>
	
	<!--- Function I was working on to convert a ColdFusion query back into an ORM array, but so far the test code take about 1 second on
	10 records, much to long --->
	<cffunction name="QueryToEntities" returnType="any">
		<cfargument name="query" type="query">
		<cfscript>
		var local.EntityArray = [];
		//Build property list
		var properties = getMetaData(this).properties;
		
		for (i=1; i LTE arguments.query.recordCount; i=i+1)
		{
			
			var workingEntity = new portal.auth.model.orm.products();
			
			for (i2=1; i2 LTE 18; i2=i2+1)
			{
				
				//writeDump(arguments.query);
				//writeDump(properties);
				//abort;
				
				//writeDump(#arguments.query["#properties[5].name#"][i]#);
				//abort;
				
				//workingEntity.setImage("");
				//abort;
				//writeDump("#properties[i2].name# <br />")
				//abort;
				if (StructKeyExists(properties[i2],"CFC"))
				{
					break;
				}
				
				local.value = arguments.query[properties[i2].name][i];
				if (local.value is "")
				{
					switch (properties[i2].type)
					{
						case "string":
						local.value = "";
						break;
						
						case "numeric":
						local.value = 0;
						break;
						
						case "date":
						local.value = DateFormat(Now(),"mm/dd/yyyy");
						break;
					}
					
				}
				
			
				
			
				
					
				//evaluate('workingEntity.set#properties[i2].name#("#local.value#")');
				
			}
			
			ArrayAppend(EntityArray, workingEntity);
			
			
		}
				
		
		
		
		</cfscript> 
		
		<!---<cfloop from="1" to="#arguments.query.recordCount#" index="i">
			<cfset workingEntity = new portal.auth.model.orm.products()>
			
			<cfloop from="1" to="#ArrayLen(properties)#" index="i2">
				<!---<cfdump var="#arguments.query["id"][i]#">
				<cfdump var="set#properties[i2].name#(#arguments.query["#properties[i2].name#"][i]#)">
				<cfabort>--->
				
				<cfabort>
				<cfinvoke component="#workingEntity#" method="setId()">
			</cfloop>
			<cfset ArrayAppend(EntityArray,workingEntity)>
		</cfloop>	--->
		
		
		<cfreturn EntityArray>
	</cffunction>
</cfcomponent>