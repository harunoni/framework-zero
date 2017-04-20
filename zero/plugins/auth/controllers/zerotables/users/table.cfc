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
		return this;
	}
}