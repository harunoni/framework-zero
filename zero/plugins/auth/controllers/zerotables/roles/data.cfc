/**
 * Represents a live browser for an entity
*/

component implements=".zero.plugins.zerotable.model.data" {

	public function init(){

		variables.entityName = "roles";
		variables.sorts = [];
		variables.params = {};
		variables.filters = [];
		return this;
	}

	public numeric function count(){

		if(!isNull(variables.countCache)){
			return variables.countCache;
		} else {
			var sql = buildQuery(count=true);
			var data = ORMExecuteQuery(sql, variables.params);
			variables.countCache = data[1];
			return variables.countCache;
		}
	}

	public function sort(required string column, required string direction){
		variables.sorts.append({column:arguments.column, direction:arguments.direction});
	};

	public array function list(required string max=10, required string offset=0){
		var sql = buildQuery();
		// writeDump(sql);
		var out = ORMExecuteQuery(sql, variables.params , false, {maxResults:arguments.max, offset:arguments.offset});
		return out;
	};

	public void function search(required string searchString){
		structDelete(variables,"countCache");
		variables.searchString = arguments.searchString;
	}

	public void function filter(required string column, required string value){
		variables.filters.append({column:arguments.column, value:arguments.value})
	}

	public function buildQuery(count=false){
		variables.params = {};
		savecontent variable="sql" {
			if(arguments.count){
				echo("select count(*) ");
			} else {
				echo("select r ");
			}

			echo(" from role r ");

			if(variables.keyExists("searchString")){
				echo ("and ( ");
				// echo("c.customerName like #param("search1", "%#variables.searchString#%")# or ");

				echo(") ");
			}

			if(variables.filters.len() GT 0){
				for(var filter in variables.filters){

					switch(filter.column){

						case "t.lastName":
							echo("and (t.lastName like '%#filter.value#%' or t.firstName like '%#filter.value#%') ");
						break;

						default:
							echo("and #filter.column# like '%#filter.value#%' ");
						break;

					}

				}
			}

			if(variables.sorts.len() GT 0){

				if(!arguments.count){
					echo("order by ");
					var i = 1;
					for(var sort in variables.sorts){
						// echo("#param(name:"sort_#i#", value:sort.column)# #param(name:"direction_#i#", value:sort.direction)#");
						if(i>1)
						echo(", ")
						echo("#sort.column# #sort.direction#");
						i++
					}
				}
			}
		}
		return sql;
	}

	private function param(required name, required value){
		variables.params.insert(arguments.name, arguments.value);
		return ":#arguments.name#"
	}

}