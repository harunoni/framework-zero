<cfscript>
/**
 * Takes a value object or string and returns a stirng
 * 
 * @param value any string or object implementing a toString() method
 * @return Returns a structure. 
 * @author Rory Laitila
 * @version 1, December 24 2016
 */
function print(required any value=""){
	return new print(arguments.value);
}
</cfscript>