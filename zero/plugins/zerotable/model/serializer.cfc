/**
*
* @file  /C/websites/portal.itr8group.com/auth/controllers/serializer.cfc
* @author
* @description test
*
*/

component output="false" displayname=""  {

	public function init(){
		variables.mode.includesAll = true;
	}

	/**
	* Takes a fprm structure and deserializes it back to keys for an entity (removes underscores)
	*/
	public function deserializeFormForEntity(required struct keys){

		var keys = arguments.keys;
		keysOut = {};
		for(var key IN keys){
			if(key IS "fieldnames"){
				continue;
			}
			var newKey = replace(key,"_","","all");
			keysOut[newKey] = trim(keys[key]);
		}
		return keysOut;
	}

	private boolean function excludesKey(key){

		if(variables.mode.includesAll == false){
			if(variables.inclusions.keyExists(arguments.key)){
				return false; //Return false because we are flipping the bit of excludesKey (doesn't exclude because its included!)
			} else {
				return true;
			}
		} else {
			if(variables.exclusions.keyExists(arguments.key)){
				return true;
			} else {
				return false;
			}
		}
	}

	public function serializeEntity(required entity, includes={}){


		if(isSimpleValue(arguments.includes)){
			var includesArray = listToArray(arguments.includes);
			var includes = {};
			for(include IN includesArray){
				includes[include] = {};
			}
			// writeDump(includes);
		} else {
			var includes = arguments.includes;
		}

		//Build exclusion keys. This allows a particular invocation
		//of the serializer to exclude certain keys which may need to be
		//ignored for performance or security reasons.
		variables.exclusions = {};
		if(includes.keyExists("@exclude")){
			var exclusionFields = arguments.includes["@exclude"];

			for(var exclusion in exclusionFields){
				if(exclusionFields[exclusion] == true){
					variables.exclusions[exclusion] = true;
				}
			}
		}

		/*
		Build inclusion keys. When @include is present, it switches
		the serialize from an includeAll by default, to a excludeAll
		by default, except those items specifically included
		 */
		variables.inclusions = {};
		if(includes.keyExists("@include")){
			variables.mode.includesAll = false;
			var inclusionFields = arguments.includes["@include"];

			for(var include in inclusionFields){
				if(!isStruct(inclusionFields[include])){
					throw("the key #include# must be a structure");
				}

				variables.inclusions[include] = true;
				includes[include] = inclusionFields[include];

			}
		}

		/*
		Allows for serializing idential recursive objects. This is handy
		when an object can recursively have children or parents
		 */
		if(includes.keyExists("@recurse")){
			for(var key in includes["@recurse"]){
				variables.inclusions[key] = true;
				includes[key] = {
					"@recurse":includes["@recurse"]
				}
			}
		}

		if(isSimpleValue(arguments.entity)){
			return arguments.entity;
		}

		if(isNull(arguments.entity)){
			return convertNullToEmptyString(arguments.entity);
		}

		if(isArray(arguments.entity)){

			if(isStruct(arguments.entity)){
				local.out = {};
				//writeDump(entity);abort;
				if(!structIsEmpty(entity)){
					for(key IN entity){

						if(excludesKey(key)){
							continue;
						}

						//writeDump(entity[key]);abort;
						if(isNull(entity[key])){
							out[camelToUnderscore(key)] = convertNullToEmptyString(entity[key]);
						}
						else {

							out[camelToUnderscore(key)] = new serializer().serializeEntity(entity[key], includes[key]?:{});
						}

					};
				}
			} else {
				local.out = [];
				for(ent IN entity){
					if(isNull(ent)){
						out.append(convertNullToEmptyString(ent?:nullValue()));
					} else {
						// writeDump(includes);
						out.append(serializeEntity(ent, includes));
					}
				};
			}

		}
		else if(isStruct(arguments.entity) AND NOT isObject(arguments.entity)){
			local.out = {};
			// writeDump(entity);
			if(!structIsEmpty(entity)){
				for(key IN entity){

					if(excludesKey(key)){
						continue;
					}

					if(isNull(entity[key])){
						out[camelToUnderscore(key)] = convertNullToEmptyString(entity[key]?:nullValue());
						// out[camelToUnderscore(key)] = "";
					} else {
						out[camelToUnderscore(key)] = new serializer().serializeEntity(entity[key], includes[key]?:{});
					}
				};
			}
		}
		else{

			if(isInstanceOf(arguments.entity, "valueObject")){
				try{
					return arguments.entity.toString();
				}catch(any e){
					writeDump(arguments.entity);
					abort;
				}
			}

			if(isInstanceOf(arguments.entity, "Optional")){
				if(arguments.entity.exists()){
					local.entity = arguments.entity.get();
				} else {
					throw "The entity via an Optional object did not exist so we cannot use it";
				}
			} else {
				local.entity = arguments.entity;
				// writeDump(local.entity);
			}
			local.prop = getAllProperties(local.entity);
			local.out = {};
			local.prop.each(function(prop){

				if(excludesKey(prop.name)){
					return; //Moveon to the next property
				}

				if(structKeyExists(prop,"cfc")){
					if(includes.keyExists(prop.name) OR (structKeyExists(prop,"fetch") AND prop.fetch CONTAINS "join"))
					{
						try{

							local.getRelation = evaluate('entity.get#prop.name#()');


							/*Check for nulls on the relation. If it is null, then we need to determine if the
							data type of the relation would normally be a struct or an array

							one-to-one & many-to-one are always structs
							many-to-many & one-to-many can be an array (default) or a struct if defined in the mapping
							*/
							if(isNull(local.getRelation) OR (isInstanceOf(local.getRelation,"Optional") AND !local.getRelation.Exists()))
							{

								if(prop.keyExists("fieldType")){
									if(prop.fieldType IS "one-to-one" OR prop.fieldType IS "many-to-one")
									{
										out[camelToUnderscore(prop.name)] = "";
									} else if(prop.fieldType IS "many-to-many" OR prop.fieldType IS "one-to-many"){

										if(structKeyExists(prop,"type") AND prop.type IS "struct")
										{
											out[camelToUnderscore(prop.name)] = {};
										}
										else
										{
											out[camelToUnderscore(prop.name)] = [];
										}

									}
								} else {
									out[camelToUnderscore(prop.name)] = "";
								}

							}
							else
							{
								if(isInstanceOf(local.getRelation,"Optional")){
									local.getRelation = local.getRelation.get();
								}
								// writeDump(prop.name);
								if(includes.keyExists(prop.name)){
									// writeDump(includes[prop.name]);
									out[camelToUnderscore(prop.name)] = new serializer().serializeEntity(local.getRelation, includes[prop.name]);
								} else {

									out[camelToUnderscore(prop.name)] = new serializer().serializeEntity(local.getRelation, {});
								}
								// writeDump(includes);
								// abort;
							}


						}catch (any e){

							writeDump(evaluate('entity.get#prop.name#()'));
							writeDump(e);
							abort;

						}
					}
				} else {
					if(!structKeyExists(prop,"serializeJson") OR (structKeyExists(prop,"serializeJson") AND prop.serializeJson IS NOT false)){

						try {
							local.getValue = evaluate('entity.get#prop.name#()');
						} catch(any e){
							throw(e);
							// // writeDump(entity);
							// writeDump(prop.name);
							// writeDump(e);
							abort;
						}

						if(isNull(local.getValue)){
							out[camelToUnderscore(prop.name)] = convertNullToEmptyString(evaluate('entity.get#prop.name#()'));
						} else if(isInstanceOf(local.getValue,"Optional")){
							if(local.getValue.exists()){
								out[camelToUnderscore(prop.name)] = convertNullToEmptyString(local.getValue.get());
							} else {
								out[camelToUnderscore(prop.name)] = convertNullToEmptyString(Javacast("null",""));
							}

							if(includes.keyExists(prop.name)){
								out[camelToUnderscore(prop.name)] = new serializer().serializeEntity(out[camelToUnderscore(prop.name)], includes[prop.name]);
							}

						} else if(isInstanceOf(local.getValue,"valueObject")){
							out[camelToUnderscore(prop.name)] = local.getValue.toString();
						}
						else if(isInstanceOf(local.getValue, "component")){
							if(includes.keyExists(prop.name)){
								out[camelToUnderscore(prop.name)] = new serializer().serializeEntity(local.getValue, includes[prop.name]);
							}
						}
						else if(isArray(local.getValue)){

							if(includes.keyExists(prop.name)){
								out[camelToUnderscore(prop.name)] = [];
								for(var item in local.getValue){

									out[camelToUnderscore(prop.name)].append(new serializer().serializeEntity(item, includes[prop.name]));
								}
							}

						}
						else {
							out[camelToUnderscore(prop.name)] = local.getValue;
						}
					}
				}
			});
		}

		return local.out;
	}
	/**
	 * Breaks a camelCased string into separate words
	 * 8-mar-2010 added option to capitalize parsed words Brian Meloche brianmeloche@gmail.com
	 *
	 * @param str      String to use (Required)
	 * @param capitalize      Boolean to return capitalized words (Optional)
	 * @return Returns a string
	 * @author Richard (brianmeloche@gmail.comacdhirr@trilobiet.nl)
	 * @version 0, March 8, 2010
	 */
	function camelToUnderscore(str) {
	    var rtnStr=lcase(reReplace(arguments.str,"([A-Z])([a-z])","_\1\2","ALL"));
	    if (arrayLen(arguments) GT 1 AND arguments[2] EQ true) {
	        rtnStr=reReplace(arguments.str,"([a-z])([A-Z])","\1_\2","ALL");
	        rtnStr=uCase(left(rtnStr,1)) & right(rtnStr,len(rtnStr)-1);
	    }
		return trim(rtnStr);
	}

	public function serializeEntities(){

	}

	private function convertNullToEmptyString(value){
		if(isNull(arguments.value)){
			return "";
		} else {
			return arguments.value;
		}
	}

	private array function getAllProperties(required component entity){

		var meta = getMetaData(arguments.entity);
		var cacheName = hash(meta.path);
		param name="application._zero.serializerMetaDataCache" default="#{}#";
		if(application._zero.serializerMetaDataCache.keyExists(cacheName)){
			return application._zero.serializerMetaDataCache[cacheName];
		} else {
			var allProperties = meta.properties;
			// writeDump(allProperties);
			if(structKeyExists(meta,"extends")){
				if(meta.extends.name != "lucee.Component"){
					try {

						if(meta.persistent == true){
							//Try the entity both by its fully qualified name
							//and its root name. This is because the extension
							//can used both paths and this may impact where the
							//entity can be loaded from
							try {
								var entity = entityNew(meta.extends.fullName);
							}catch(any e){

								var entityName = listLast(meta.extends.fullName, ".");
								var entity = entityNew(entityName);
								// writeDump(entity);
								// writeDump(entityNew("users"));
								// abort;
							}
							var parent.meta = getMetaData(entity);
						} else {

							var parent.meta = getComponentMetaData(meta.extends.fullName);
						}

					} catch(any e){
						writeDump(e);
						writeDump(meta.extends.fullName);
						writeDump(meta);
						abort;
					}

					// writeDump(parent.meta);
					// abort;
					if(structKeyExists(parent.meta,"persistent") AND parent.meta.persistent IS true){
						allProperties = allProperties.merge(parent.meta.properties);
					}
				} else {

				}
			}
			application._zero.serializerMetaDataCache[cacheName] = allProperties;
			return allProperties;
		}
	}

}