/**
*
* @file  /C/websites/portal.itr8group.com/auth/controllers/serializer.cfc
* @author
* @description test
*
*/

component output="false" displayname=""  {

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

	public function serializeEntity(required entity, includes=""){

		if(isSimpleValue(arguments.includes)){
			var includesArray = listToArray(arguments.includes);
			var includes = {};
			for(include IN includesArray){
				includes[include] = {};
			}
			// writeDump(includes);
		}

		if(isArray(arguments.entity)){

			local.out = [];
			for(ent IN entity){
				out.append(serializeEntity(ent, includes));
			};
		}
		else if(isStruct(arguments.entity) AND NOT isObject(arguments.entity)){
			local.out = {};
			//writeDump(entity);abort;
			if(!structIsEmpty(entity)){
					for(key IN entity){
					//writeDump(entity[key]);abort;
					out[camelToUnderscore(key)] = serializeEntity(entity[key], includes);
				};
			}

		}
		else{

			if(isInstanceOf(arguments.entity, "Optional")){
				if(arguments.entity.exists()){
					local.entity = arguments.entity.get();
				} else {
					throw "The entity via an Optional object did not exist so we cannot use it";
				}
			} else {
				local.entity = arguments.entity;
			}

			local.prop = getAllProperties(local.entity);
			local.out = {};
			local.prop.each(function(prop){
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
							writeDump(prop.name);
							writeDump(e);
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
		var allProperties = meta.properties;

		if(structKeyExists(meta,"extends")){
			var parent.meta = getComponentMetaData(meta.extends.fullName);

			if(structKeyExists(parent.meta,"persistent") AND parent.meta.persistent IS true){
				allProperties = allProperties.merge(parent.meta.properties);
			}
		}

		return allProperties;
	}





}
