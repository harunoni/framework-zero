/**
 * Represents a live browser for an entity
*/
import _vendor.cborm.models.BaseORMService;
component implements="data" {
	public function init(){

		//BUILD QUERY/SORTING CRITERIA
		var ORM = new BaseORMService(useQueryCaching=false,
		eventHandling=false,
		useTransactions=true,
		defaultAsQuery=false);
		variables.Criteria = ORM.newCriteria("product");

		return this;
	}

	public int function count(){
		return variables.Criteria.count();
	}

	public function sort(required string column, required string direction){};
	
	public array function list(){
		return variables.Criteria.list();
	};


}