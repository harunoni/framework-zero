/**
 * The entry point for a zeroTable
 * @type {String}
 */
import _vendor.queryString.queryString;
component accessors="true" {
	
	property name="rows" setter="false";
	property name="columns" setter="false";
	property name="primaryColumn" setter="false";
	property name="pagination" setter="false";
	property name="max";
	property name="offset";
	property name="sort";
	property name="direction";
	property name="currentPageId";
	property name="search" setter="false";
	property name="currentLink" setter="false";
	property name="currentParams" setter="false";
	property name="currentParamsAsString" setter="false";
	property name="clearSearchLink" setter="false";
	property name="clearEditLink" setter="false";
	property name="basePath" setter="false";

	public function init(required data Rows, required numeric max=10, required numeric offset=1, showMaxPages=5, string basePath){
		variables.Rows = arguments.Rows;
		variables.max = arguments.max;
		variables.offset = arguments.offset;
		variables.columns = [];
		variables.showMaxPages = arguments.showMaxPages;
		variables.currentPageId = 1;
		variables.isSortedById = false;
		variables.basePath = arguments.basePath;
		variables.convertCamelCaseToUnderscore = false;
		// variables.searchString = "";
		variables.qs = new queryString(cgi.query_string);
		variables.qs.setBasePath(arguments.basePath & "/list");
		// variables.qs.setValues({
		// 	"max":variables.max,
		// 	"offset":variables.offset
		// });
	}

	
	public function addColumn(required column column){
		var column = arguments.column;

		if(variables.convertCamelCaseToUnderscore){
			column.setColumnName(camelToUnderscore(column.getColumnName()));
		}

		var found = variables.columns.some(function(check){
			if(check.equals(column)){
				return true;
			} else {
				return false;
			}
		});
		if(!found){

			if(column.getIsPrimary()){
				variables.primaryColumn = new optional(Column);
			}

			variables.columns.append(column);
			column.setSortAscLink(variables.qs.getNew().setValues({"sort":column.getColumnName(), "direction":"asc"}).get());
			column.setSortDescLink(variables.qs.getNew().setValues({"sort":column.getColumnName(), "direction":"desc"}).get());

		} else {
			throw("column already exists");
		}
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

	public function edit(required string columnName, required string rowId, string errorMessage){


		var column = findColumnByName(arguments.columnName).elseThrow("Could not find the column #columnName#");
		column.setEdit(true);

		if(arguments.keyExists("errorMessage")){
			column.setErrorMessage(arguments.errorMessage);
		}

		var primaryColumn = getPrimaryColumn().elseThrow("Can only edit tables which have a primary column. Add a primary column");
		variables.qs.setValues({"edit_col":primaryColumn.getColumnName(), "edit_id":rowId});
		for(var row in getRows()){
			var name = primaryColumn.getColumnName();
			if(row[name] == arguments.rowId){
				row.edit = true;

				if(arguments.keyExists("errorMessage")){
					row.error_message = arguments.errorMessage;
				}

			} else {
				row.edit = false;
			}
		}		
	}

	public Optional function findColumnByName(required string columnName){
		var columnName = arguments.columnName;
		var found = variables.columns.find(function(column){
			if(lcase(column.getColumnName()) == columnName){
				return true;
			} else {
				return false;
			}
		});
		if(!found){
			return new optional();
		} else {
			return new optional(getColumns()[found]);
		}
	}

	public string function getClearEditLink(){
		return variables.qs.getNew().delete("edit_col").delete("edit_id").get();
	}

	public string function getClearSearchLink(){
		return variables.qs.getNew().setBasePath("#variables.basePath#/list")
									.delete("search")
									.delete("edit_col")
									.delete("edit_id").get();
	}

	public string function getCurrentLink(){
		return variables.qs.getNew().setBasePath("/zerotable/main/list").get();
	}

	public pagination function getPagination(){

		return new pagination(data=variables.Rows, 
							  max=variables.max, 
							  offset=variables.offset, 
							  queryString=variables.qs,							 
							  showMaxPages=variables.showMaxPages);
	}

	public array function getCurrentParams(){

		var params = ["offset", "max", "search", "sort", "direction"];
		var out = [];
		for(var param in params){

			var value = evaluate("this.get#param#()");
			if(isInstanceOf(value,"optional")){
				if(!value.exists()){
					continue;
				}
			} 		

			if(!isNull(value)){
				out.append({
					"name":param,
					"value":evaluate("this.get#param#()"),
					"is_#param#":true
				});				
			}
		}
		return out;
	}

	public string function getCurrentParamsAsString(){
		return variables.qs.getNew().setBasePath("").get();
	}

	public optional function getPrimaryColumn(){
		return variables.primaryColumn?: new optional();
	}

	public function getRows(){

		if(!variables.isSortedById){
			variables.Rows.sort("id", "asc");
		}

		if(isNull(variables.serializedRows)){
			var rows = variables.Rows.list(max=variables.max, offset=variables.offset);
			var rows = new serializer().serializeEntity(rows);
			variables.serializedRows = rows;			
		} 
		return variables.serializedRows;
	}

	public Optional function getsearch(){
		if(isNull(variables.searchString)){
			return new Optional();
		} else {
			return new Optional(variables.searchString);
		}
	}

	public void function pageTo(required numeric id){
		variables.currentPageId = arguments.id;
	}

	public void function search(required string search){
		variables.searchString = arguments.search;
		variables.qs.setValues({"search":variables.searchString});
		variables.Rows.search(arguments.search);
	}

	public void function sort(required string column, required string direction){
		
		var column = findColumnByName(arguments.column).elseThrow("The column name #arguments.column# was not a valid name");
		
		variables.Rows.sort(column=column.getDataName(), direction=arguments.direction);

		if(column.getIsPrimary()){
			variables.isSortedById = true;
		}

		variables.sort = column.getColumnName();
		variables.direction = arguments.direction;
		
		
		variables.qs.setValues({"sort":column.getColumnName(), direction:arguments.direction});
		column.setIsSorted(true);		
		if(direction == "asc"){
			column.setIsSortedAsc(true);
		} else {
			column.setIsSortedDesc(true);
		}

	};

	public struct function toStructure(){
		var zeroTableOut = new serializer().serializeEntity(this, {
			rows:{

			},
			columns:{
				filter:{}
			},
			primaryColumn:{},
			pagination:{
				firstPage:{},
				lastPage:{},
				currentPage:{},
				nextPage:{},
				previousPage:{},
				summaryPages:{}

			},
			currentParams:{}
		});
		return zeroTableOut;
	}

}