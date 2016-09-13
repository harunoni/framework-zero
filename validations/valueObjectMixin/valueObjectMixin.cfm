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

	function nl(){
		var nl = CreateObject("java", "java.lang.System").getProperty("line.separator");
		echo(nl);
	}

	objs = ["emailAddress"];
	closures = {}
	for(obj in propsOut){

		// uuidName = replaceNoCase(createUUID(),"-","","all");
		entityName = getMetaData(this).name;
		entityName = listLast(entityName,".");
		uuidName = "#entityName#_#obj.name#_#obj.type#";
		// fileName = "foo";
		savecontent variable="func"{
			nl();
			echo("function set#obj.name#(value){");
				nl();
				// echo("var type = '#obj.type#';");
				// echo("var name = '#obj.name#';");
				// echo("writeDump(arguments);")
				// echo("writeDump(local);");
				// echo("var name = #obj.name#;");
				
				echo("if(isInstanceof(arguments.value, '#obj.type#')){")
					nl();
					echo("variables.#obj.name# = arguments.value.toString();")
					nl();
				echo("} else {"); nl();

					echo("variables.#obj.name# = new #obj.type#(value=arguments.value).toString();"); nl();

				echo("}"); nl();

				// echo("writeDump(isInstanceof(arguments.value, type))");

			echo("}"); nl();

			echo("function get#obj.name#(value){"); nl();

				// echo("var type = '#obj.type#';");
				// echo("var name = '#obj.name#';");
				echo("if(isNull(variables.#obj.name#)){"); nl();
					echo("return nullValue()"); nl();
				echo("} else {"); nl();
					echo("return new #obj.type#(value=variables.#obj.name#?:nullValue());"); nl();
				echo("}"); nl();

			echo("}"); nl();

		}
		// fileWrite("#uuidName#.cfm", "<cfscript>#func#</cfscript>");
		
		fileWrite("#uuidName#.cfm", "<cfscript>#func#</cfscript>");
		include template="#uuidName#.cfm";
		// fileDelete("#uuidName#.cfm");

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