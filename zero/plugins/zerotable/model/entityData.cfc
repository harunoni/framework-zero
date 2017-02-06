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

		//Cannot have order by's when calling count on a criteria, so
		//we keep a seperate critera to keep track of the count
		variables.CountCriteria = ORM.newCriteria("product");

		return this;
	}

	public function getCriteria(){
		return variables.Criteria;
	}

	public numeric function count(){

		if(!isNull(variables.countCache)){
			return variables.countCache;
		} else {
			variables.countCache = variables.CountCriteria.count();						
			return variables.countCache;
		}						
	}

	public function sort(required string column, required string direction){		
		// structDelete(variables,"countCache");
		variables.Criteria.order(arguments.column, arguments.direction);		
	};
	
	public array function list(required string max=10, required string offset=1){
		return variables.Criteria.list(max=arguments.max, offset=arguments.offset);
	};

	public void function search(required string searchString){		
		// structDelete(variables,"countCache");
		variables.Criteria.OR(
				//At beginning of string
				// Criteria.restrictions.like("category","#search#%"),
				// Criteria.restrictions.like("name","#search#%"),					
				// Criteria.restrictions.like("price","#search#%"),

				
				Criteria.restrictions.ilike("name","%#arguments.searchString#%"),					
				Criteria.restrictions.ilike("category","%#arguments.searchString#%"),
				Criteria.restrictions.ilike("price","%#arguments.searchString#%")

				
				// Criteria.restrictions.like("category","%#search#"),
				// Criteria.restrictions.like("name","%#search#"),					
				// Criteria.restrictions.like("price","%#search#")
			)		

	}


}