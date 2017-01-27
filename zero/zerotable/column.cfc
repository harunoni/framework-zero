/**
 * Represents a configuration for a particular column
*/
component accessors="true"{

	property name="columnName" setter="false";
	property name="isSorted" type="boolean";
	property name="isSortedDesc" type="boolean";
	property name="isSortedAsc" type="boolean";
	property name="sortAscLink" type="boolean";
	property name="sortDescLink";
	property name="edit" type="boolean";
	property name="editable" type="boolean";
	property name="columnType" type="struct" setter="false";

	public function init(required string columnName, 
						 boolean editable, 
						 struct columnType){
		variables.columnName = arguments.columnName;

		if(arguments.keyExists("columnType")){
			variables.columnType = arguments.columnType;
		} else {
			variables.columnType = {"text":true}	
		}

		return this;
	}

	public function equals(required column){
		if(arguments.column.getColumnName() == variables.columnName){
		return true
		} else {
			return false;
		}
	}
}