/**
 * Represents an individual page
*/
component accessors="true" {

	property name="id" setter="false";
	property name="link" setter="false";
	property name="startIndex" setter="false";
	property name="endIndex" setter="false";
	property name="isCurrentPage" setter="false";

	public function init(required numeric id, required string link, required numeric startIndex, required numeric endIndex, required boolean isCurrentPage){
		variables.id = arguments.id;
		variables.link = arguments.link;
		variables.startIndex = arguments.startIndex;
		variables.endIndex = arguments.endIndex;
		variables.isCurrentPage = arguments.isCurrentPage;
		return this;
	}

	public function equals(required page page){
		if(variables.id == arguments.page.getId()){
			return true;
		} else {
			return false;
		}
	}
}