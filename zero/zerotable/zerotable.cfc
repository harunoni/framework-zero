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


	public function init(required Rows Rows, required numeric max=10, required numeric offset=1, showMaxPages=10){
		variables.Rows = arguments.Rows;
		variables.max = arguments.max;
		variables.offset = arguments.offset;
		variables.columns = [];
		variables.showMaxPages = arguments.showMaxPages;
		variables.currentPageId = 1;
		variables.qs = new queryString(cgi.query_string);
	}

	
	public function addColumn(required column column){
		var column = arguments.column;
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
			column.setSortAscLink(variables.qs.getNew().setValues({"sort":column.getColumnName(), "dir":"asc"}).get());
			column.setSortDescLink(variables.qs.getNew().setValues({"sort":column.getColumnName(), "dir":"desc"}).get());

		} else {
			throw("column already exists");
		}
	}

	public function edit(required string columnName, required string rowId){

		var column = findColumnByName(arguments.columnName).elseThrow("Could not find the column #columnName#");
		column.setEdit(true);
		var primaryColumn = getPrimaryColumn().elseThrow("Can only edit tables which have a primary column. Add a primary column");

		for(var row in getRows()){
			var name = primaryColumn.getColumnName();
			if(row[name] == arguments.rowId){
				row.edit = true;
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

	public pagination function getPagination(){
		return new pagination(data=variables.Rows, max=variables.max, queryString=variables.qs, currentPageId=variables.currentPageId, showMaxPages=variables.showMaxPages);
	}

	public optional function getPrimaryColumn(){
		return variables.primaryColumn?: new optional();
	}

	public function getRows(){

		if(isNull(variables.serializedRows)){
			var rows = variables.Rows.list(max=variables.max, offset=variables.offset);
			var rows = new serializer().serializeEntity(rows);
			variables.serializedRows = rows;			
		} 
		return variables.serializedRows;
	}

	public void function pageTo(required numeric id){
		variables.currentPageId = arguments.id;
	}

	public function sort(required string column, required string direction){
		variables.Rows.sort(argumentCollection=arguments);
		var column = findColumnByName(arguments.column).elseThrow("The column name #arguments.column# was not a valid name");

		variables.sort = column.getColumnName();
		variables.direction = arguments.direction;
		variables.qs.setValues({"sort":column.getColumnName(), dir:arguments.direction});
		column.setIsSorted(true);		
		if(direction == "asc"){
			column.setIsSortedAsc(true);
		} else {
			column.setIsSortedDesc(true);
		}

	};

}