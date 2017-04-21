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
		return this;
	}
}