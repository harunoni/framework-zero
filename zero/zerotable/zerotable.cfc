/**
 * The entry point for a zeroTable
 * @type {String}
 */
component accessors="true" {
	
	property name="data" setter="false";
	property name="columns" setter="false";
	property name="pagination" setter="false";

	public function init(required data data){
		variables.data = arguments.data;
		variables.columns = [];
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
			variables.columns.append(column);
		} else {
			throw("column already exists");
		}
	}

	public function getData(){
		return variables.data.list();
	}

	public pagination function getPagination(){
		return new pagination(variables.data);
	}

}