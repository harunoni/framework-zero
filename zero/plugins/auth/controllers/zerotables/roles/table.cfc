/**
*/
import .zero.plugins.zerotable.model.*
component extends=".zero.plugins.zerotable.model.zeroTable" {
	public function init(){
		arguments.rows = new data();

		arguments.tableName = "roles";
		arguments.basePath = "/auth/roles/list";
		arguments.useZeroAjax = false;
		arguments.serializerIncludes = {
		}

		super.init(argumentCollection=arguments);


		this.addColumn(new column(columnName="id", isPrimary="true", wrap='<a href="/auth/roles/{{value}}">{{value}}</a>'));
		this.addColumn(new column(columnName="name", dataName="r.name"));
		this.addColumn(new column(columnName="description", dataName="r.description"));
		this.addColumn(new column(columnName="delete", friendlyName="Delete Role", sortable="false", columnType={
				"custom":true,
				"output":function(row){
					var out = '
					<button id="confirm#row.id#" class="btn btn-xs btn-primary" onClick="$(''##delete#row.id#'').show(); $(this).hide();">Delete</button>
					<span id="delete#row.id#" style="display:none;">
					<form action="/auth/roles/#row.id#/delete" method="post" style="display:inline;">
						<span>Are you sure? Deleted roles will have their permissions removed from all users with this role.</span>
						<input type="hidden" name="goto" value="/auth/roles/list" />
						<button class="btn btn-xs btn-warning">Yes</button>
				   	</form>
					<button class="btn btn-xs btn-default" onClick="$(''##delete#row.id#'').hide(); $(''##confirm#row.id#'').show(); return false;">Cancel</button>
					</span>'
				   return out;
				}
			}))
		return this;
	}
}