<!---
Author: Rory Laitila
Purpose: Provide generated methods for properties that use value objects in ORM Entities

This valueObjectMixin will create getters and setters for any properties which implement 
a complex type (not one of the basic CFML types). The functions generated will have the signature:

function setProp(value){
	
}

function getProp(){
	
}
--->
<cfscript>

function getInternalVariablesReference(){
	return variables;
}

cfmltypes = [
		"any",
		"array",
		"binary",
		"boolean",
		"component",
		"date",
		"guid",
		"numeric",
		"query",
		"string",
		"struct",
		"uuid",
		"variableName",
		"void"						
	];

	this.meta = getMetaData(this).properties;
	
	propsOut = [];
	for(prop in this.meta){
		if(prop.keyExists("fieldtype")){
			continue;
		}

		if(prop.keyExists("type") and arrayFind(cfmlTypes, prop.type)){
			continue;			
		}

		if(prop.keyExists("type")){
			//Should be a custom value object
			propsOut.append(prop);					
		}
	}

	function getMeta(){
		return propsOut;
	}

	objs = ["emailAddress"];
	closures = {}
	for(obj in propsOut){

		// uuidName = replaceNoCase(createUUID(),"-","","all");
		uuidName = "#obj.name#_#obj.type#";
		// fileName = "foo";
		savecontent variable="func"{

			echo("function set#obj.name#(value){");

				// echo("var type = '#obj.type#';");
				// echo("var name = '#obj.name#';");
				// echo("writeDump(arguments);")
				// echo("writeDump(local);");
				// echo("var name = #obj.name#;");
				
				echo("if(isInstanceof(arguments.value, '#obj.type#')){")

					echo("variables.#obj.name# = arguments.value.toString();")

				echo("} else {")

					echo("variables.#obj.name# = new #obj.type#(arguments.value).toString();")

				echo("}")

				// echo("writeDump(isInstanceof(arguments.value, type))");

			echo("}")

			echo("function get#obj.name#(value){");

				// echo("var type = '#obj.type#';");
				// echo("var name = '#obj.name#';");
				echo("if(isNull(variables.#obj.name#)){")				
					echo("return nullValue()");
				echo("} else {")
					echo("return new #obj.type#(variables.#obj.name#?:nullValue());")
				echo("}")

			echo("}")

		}
		// fileWrite("#uuidName#.cfm", "<cfscript>#func#</cfscript>");
		fileWrite("#uuidName#.cfm", "<cfscript>#func#</cfscript>");
		include template="#uuidName#.cfm";
		fileDelete("#uuidName#.cfm");

			// "set#obj.name#" = function(value){			
			// 	writeDump(closures);
			// }

			// "get#obj.name#" = function(){
				
			// }

			// closures.append({
			// 	"#obj.name#":this["set#obj.name#"]
			// });

	}
	
</cfscript>