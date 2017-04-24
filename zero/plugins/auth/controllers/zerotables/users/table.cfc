/**
*/
import .zero.plugins.zerotable.model.*
component extends=".zero.plugins.zerotable.model.zeroTable" {
	public function init(){
		arguments.rows = new data();

		arguments.tableName = "users";
		arguments.basePath = "/auth/users/list";

		super.init(argumentCollection=arguments);

		this.addColumn(new column(columnName="id", isPrimary="true", wrap='<a href="/auth/users/{{value}}">{{value}}</a>'));
		this.addColumn(new column(columnName="first_name", dataName="u.firstName"));
		this.addColumn(new column(columnName="last_name", dataName="u.lastName"));
		this.addColumn(new column(columnName="delete", friendlyName="Delete User", sortable="false", columnType={
				"custom":true,
				"output":function(row){
					var out = '
					<button id="confirm#row.id#" class="btn btn-xs btn-primary" onClick="$(''##delete#row.id#'').show(); $(this).hide();">Delete</button>
					<span id="delete#row.id#" style="display:none;">
					<form action="/auth/users/#row.id#/delete" method="post" style="display:inline;">
						<span>Are you sure? Deleted users will have their permissions revoked and will be logged out</span>
						<input type="hidden" name="goto" value="/auth/users/list" />
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