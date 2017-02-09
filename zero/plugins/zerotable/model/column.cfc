/**
 * Represents a configuration for a particular column
*/
component accessors="true"{

	property name="columnName" setter="false";	
	property name="dataName" setter="false";
	property name="errorMessage";
	property name="friendlyName" setter="false";
	property name="hidden" setter="false";
	property name="hasWrap" setter="false";
	property name="isSorted" type="boolean";
	property name="isSortedDesc" type="boolean";
	property name="isSortedAsc" type="boolean";
	property name="sortAscLink";
	property name="sortDescLink";
	property name="edit" type="boolean";
	property name="editable" type="boolean";
	property name="columnType" type="struct" setter="false";
	property name="isPrimary" type="boolean" setter="false";
	property name="filter" type="array" setter="false";
	property name="filterable" type="boolean" setter="false"; 

	public function init(required string columnName,
						 string friendlyName, 
						 boolean editable=false, 
						 struct columnType,
						 boolean isPrimary=false,
						 array filter,
						 hidden = false
						 ){
		variables.columnName = arguments.columnName;

		if(arguments.keyExists("columnType")){
			variables.columnType = arguments.columnType;
		} else {
			variables.columnType = {"text":true}	
		}

		if(arguments.keyExists("friendlyName")){
			variables.friendlyName = arguments.friendlyName;
		} else {
			variables.friendlyName = arguments.columnName;
		}

		if(arguments.keyExists("dataName")){
			variables.dataName = arguments.dataName;			
		} else {
			variables.dataName = arguments.columnName;
		}

		if(arguments.keyExists("filter")){
			variables.filter = arguments.filter;
			variables.filterable = true;
		} else {
			variables.filterable = false;			
		}

		if(arguments.keyExists("Wrap")){
			variables.Wrap = arguments.Wrap;
			variables.hasWrap = true;
		} else {
			variables.hasWrap = false;
			variables.Wrap = "{{value}}";
		}

		variables.customOutput = "";

		variables.isPrimary = arguments.isPrimary;
		variables.editable = arguments.editable;
		variables.isSorted = false;
		variables.isSortedDesc = false;
		variables.isSortedAsc = false;
		variables.hidden = arguments.hidden;
		// variables.queryString = arguments.queryString;
		return this;
	}

	public function equals(required column){
		if(arguments.column.getColumnName() == variables.columnName){
			// writeDump(variables.columnName);
			// writeDump(arguments.column.getColumnName());
			return true
		} else {
			return false;
		}
	}

	public function getColumnType(){

		if(variables.columnType.keyExists("custom")){			
			var out = duplicate(variables.columnType);
			if(isClosure(out.output)){
				out.output = "function call";
			}			
			return out;
		}

		return variables.columnType;

	}

	public function getCustomOutput(required struct row){

		var out = "";
		if(variables.columnType.keyExists("custom") and variables.columnType.custom){
			if(isSimpleValue(variables.columnType.output)){
				out = variables.columnType.output;
			} else if(isClosure(variables.columnType.output)){
				out = evaluate("variables.columnType.output(arguments.row)");
			}
			else {
				out = variables.customOutput;
			}
		}		
		return out;
	}

	public function getWrapOutput(required string value){
		var out = replaceNoCase(variables.Wrap, "{{value}}", arguments.value, "all");
		return out;
	}

	public function getSortAscLink(){
		return variables.queryString.getNew().delete("DIRECTION").setValues({"sort":getColumnName(), "direction":"asc"}).get();
	}

	public function getSortDescLink(){
		return variables.queryString.getNew().delete("DIRECTION").setValues({"sort":getColumnName(), "direction":"desc"}).get();
	}

	public function setIsSortedAsc(){
		variables.isSortedAsc = true;
		variables.isSortedDesc = false;
	}

	public function setIsSortedDesc(){
		variables.isSortedAsc = false;
		variables.isSortedDesc = true;
	}

	public function setQueryString(required queryString queryString){
		variables.queryString = arguments.queryString;
	}

	/**
	 * Make setColumnName package available so that zerotable can change it to underscores if desired
	 */
	package function setColumnName(string columnName){
		variables.columnName = arguments.columnName;
	}
	
}