/**
*/
import .zero.plugins.zerotable.model.*
component extends=".zero.plugins.zerotable.model.zeroTable" {
	public function init(){
		arguments.rows = new data();

		arguments.tableName = "resources";
		arguments.basePath = "/auth/resources/list";
		arguments.useZeroAjax = false;
		arguments.serializerIncludes = {
			parent:{

			}
		}

		super.init(argumentCollection=arguments);


		this.addColumn(new column(columnName="id", isPrimary="true"));
		this.addColumn(new column(columnName="name", dataName="r.name"));
		this.addColumn(new column(columnName="description", dataName="r.description"));
		this.addColumn(new column(columnName="parent", dataName="r.parent.name", columnRowDataPath="parent.name"));
		return this;
	}
}