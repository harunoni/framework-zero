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
	property name="isFiltered" type="boolean";
	property name="isSorted" type="boolean";
	property name="isSortedDesc" type="boolean";
	property name="isSortedAsc" type="boolean";
	property name="sortAscLink";
	property name="sortDescLink";
	property name="edit" type="boolean";
	property name="editable" type="boolean";
	property name="sortable" type="boolean" default="true";
	property name="columnType" type="struct" setter="false";
	property name="isPrimary" type="boolean" setter="false";
	property name="filter" type="array" setter="false";
	property name="filterable" type="boolean" setter="false";
	property name="width" type="string" setter="false";
	property name="textAlign" type="string" setter="false";
	property name="columnRowDataPath" type="string" hint="The json path to the column data from the row" setter="false";

	public function init(required string columnName,
						 string friendlyName,
						 string columnRowDataPath,
						 boolean editable=false,
						 struct columnType,
						 boolean isPrimary=false,
						 struct filter,
						 hidden = false,
						 sortable = true,
						 width="",
						 textAlign="left",
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
			if(arguments.filter.keyExists("value")){
				setFilteredValue(arguments.filter.value);
			}

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

		if(arguments.keyExists("columnRowDataPath")){
			variables.columnRowDataPath = arguments.columnRowDataPath;
		} else {
			variables.columnRowDataPath = arguments.columnName;
		}

		variables.textAlign = arguments.textAlign;
		variables.width = arguments.width;

		variables.customOutput = "";

		variables.isPrimary = arguments.isPrimary;
		variables.editable = arguments.editable;
		variables.sortable = arguments.sortable;
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
				if(variables.keyExists("zeroTable")){
					out = evaluate("variables.columnType.output(arguments.row, variables.zeroTable)");
				} else {
					out = evaluate("variables.columnType.output(arguments.row)");
				}
			}
			else {
				out = variables.customOutput;
			}
		}
		return out;
	}

	public function getInputName(){
		return zeroTable.getFieldNameWithTablePrefix(this.getColumnName());
	}

	public function getWrapOutput(required string value){
		var out = replaceNoCase(variables.Wrap, "{{value}}", arguments.value, "all");
		return out;
	}

	public function getSortAscLink(){
		return variables.zeroTable.getQueryString().getNew().delete(variables.zeroTable.getFieldNameWithTablePrefix("direction")).setValues({"#variables.zeroTable.getFieldNameWithTablePrefix("sort")#":getColumnName(), "#variables.zeroTable.getFieldNameWithTablePrefix("direction")#":"asc"}).get();
	}

	public function getSortDescLink(){
		return variables.zeroTable.getQueryString().getNew().delete(variables.zeroTable.getFieldNameWithTablePrefix("direction")).setValues({"#variables.zeroTable.getFieldNameWithTablePrefix("sort")#":getColumnName(), "#variables.zeroTable.getFieldNameWithTablePrefix("direction")#":"desc"}).get();
	}

	public function setFilteredValue(required any value){
		variables.filter.value = arguments.value;
		variables.isFiltered = true;
	}

	public function setIsSortedAsc(){
		variables.isSortedAsc = true;
		variables.isSortedDesc = false;
	}

	public function setIsSortedDesc(){
		variables.isSortedAsc = false;
		variables.isSortedDesc = true;
	}

	public function setZeroTable(required zeroTable zeroTable){
		variables.zeroTable = arguments.zeroTable;
	}

	/**
	 * Make setColumnName package available so that zerotable can change it to underscores if desired
	 */
	package function setColumnName(string columnName){
		variables.columnName = arguments.columnName;
	}

	public function toJson(){
		var out = {
			"column_name":this.getcolumnName(),
			"column_row_data_path":this.getColumnRowDataPath(),
			"data_name":this.getdataName(),
			"error_message":this.geterrorMessage(),
			"friendly_name":this.getfriendlyName(),
			"hidden":this.gethidden(),
			"has_wrap":this.gethasWrap(),
			"is_sorted":this.getisSorted(),
			"is_sorted_desc":this.getisSortedDesc(),
			"is_sorted_asc":this.getisSortedAsc(),
			"sort_asc_link":this.getsortAscLink(),
			"sort_desc_link":this.getsortDescLink(),
			"edit":this.getedit(),
			"editable":this.geteditable(),
			"column_type":this.getcolumnType(),
			"is_primary":this.getisPrimary(),
			"is_filtered":this.getIsFiltered(),
			"filter":this.getfilter(),
			"filterable":this.getfilterable(),
			"sortable":this.getSortable(),
			"text_align":this.getTextAlign(),
			"width":this.getWidth(),
			"input_name":this.getInputName()

		}
		return out;
	}

}