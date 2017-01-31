/**
 * Represents a configuration for a particular column
*/
component accessors="true"{

	property name="columnName" setter="false";
	property name="isSorted" type="boolean";
	property name="isSortedDesc" type="boolean";
	property name="isSortedAsc" type="boolean";
	property name="sortAscLink";
	property name="sortDescLink";
	property name="edit" type="boolean";
	property name="editable" type="boolean";
	property name="columnType" type="struct" setter="false";
	property name="isPrimary" type="boolean" setter="false";

	public function init(required string columnName, 
						 boolean editable=false, 
						 struct columnType,
						 boolean isPrimary=false){
		variables.columnName = arguments.columnName;

		if(arguments.keyExists("columnType")){
			variables.columnType = arguments.columnType;
		} else {
			variables.columnType = {"text":true}	
		}

		variables.isPrimary = arguments.isPrimary;
		variables.editable = arguments.editable;
		variables.isSorted = false;
		variables.isSortedDesc = false;
		variables.isSortedAsc = false;
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

	public function setIsSortedAsc(){
		variables.isSortedAsc = true;
		variables.isSortedDesc = false;
	}

	public function setIsSortedDesc(){
		variables.isSortedAsc = false;
		variables.isSortedDesc = true;
	}
}