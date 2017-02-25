/**
*/
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

	public function init(
							integer offset=new integer(0),
							integer more = new integer(10),
							integer max = new integer(10),
							integer page = new integer(1),		
							string sort,
							string direction,
							string search,
							string edit_col,
							integer edit_id,
		){

		variables.offset = arguments.offset.toString();
		variables.more = arguments.more.toString();
		variables.max = arguments.max.toString();
		variables.page = arguments.page.toString();
		variables.sort = arguments.sort.toString();
		variables.direction = arguments.direction.toString();
		variables.goto_page = arguments.goto_page.toString();
		variables.search = arguments.search.toString();
		variables.edit_col = arguments.edit_col.toString();
		variables.edit_id = arguments.edit_id.toString();
		return this;
	}
}