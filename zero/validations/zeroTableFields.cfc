/**
 * Value object for a zeroTable
*/
import zero.plugins.zeroTable.model.zeroTable;
component accessors="true"{

	property name="offset" setter="false";
	property name="more" setter="false";
	property name="max" setter="false";
	property name="page" setter="false";
	property name="sort" setter="false";
	property name="direction" setter="false";
	property name="goto_page" setter="false";
	property name="search" setter="false";
	property name="edit_col" setter="false";
	property name="edit_id" setter="false";
	property name="table_name" setter="false";

	public function init(
							numeric offset = 0,
							numeric more,
							numeric max = 10,
							numeric page = 1,
							numeric goto_page,
							string sort,
							string direction,
							string search,
							string edit_col,
							numeric edit_id,
							string row_edit_panel,
							string table_name
		){

		if(arguments.keyExists("offset")) { variables.offset = arguments.offset; }
		if(arguments.keyExists("more")) { variables.more = arguments.more; }
		if(arguments.keyExists("max")) { variables.max = arguments.max; }
		if(arguments.keyExists("page")) { variables.page = arguments.page; }
		if(arguments.keyExists("sort")) { variables.sort = arguments.sort; }
		if(arguments.keyExists("direction")) { variables.direction = arguments.direction; }
		if(arguments.keyExists("goto_page")) { variables.goto_page = arguments.goto_page; }
		if(arguments.keyExists("search")) { variables.search = arguments.search; }
		if(arguments.keyExists("edit_col")) { variables.edit_col = arguments.edit_col; }
		if(arguments.keyExists("edit_id")) { variables.edit_id = arguments.edit_id; }
		if(arguments.keyExists("table_name")) { variables.table_name = arguments.table_name; }
		if(arguments.keyExists("row_edit_panel")) { variables.row_edit_panel = arguments.row_edit_panel; }
		return this;
	}

	public function createZeroTable(required data rows, string basePath="", useZeroAjax=false, struct persistFields={}, columns=[]){

		var creationArgs = {
			rows=arguments.rows,
			basePath=arguments.basePath,
			useZeroAjax=arguments.useZeroAjax,
			persistFields=arguments.persistFields
		}

		creationArgs.append(variables);

		if(variables.keyExists("table_name")){
			// abort;
			creationArgs.tableName = variables.table_name;
		}

		//Create a zero table
		zeroTable = new zero.plugins.zeroTable.model.zeroTable(argumentCollection=creationArgs
								  );
		// writeDump(creationArgs);
		for(var column in arguments.columns){
			zeroTable.addColumn(column);
		}
		return zeroTable;
	}

	public function toStruct(){

		var keys = [
			"offset",
			"more",
			"max",
			"page",
			"sort",
			"direction",
			"goto_page",
			"search",
			"edit_col",
			"edit_id",
			"table_name"
		];
		var out = {}
		for(var key in keys){
			if(variables.keyExists(key)){
				out.insert(key, variables[key]);
			}
		}
		return out;
	}
}