/**
 * Represents a pagination
*/
component accessors="true" {

	property name="currentPage" setter="false"; //
	property name="dir" setter="false";
	property name="firstPage" setter="false"; //
	property name="hasNextPage" setter="false"; //
	property name="hasPreviousPage" setter="false"; //
	property name="isFirstPage" setter="false"; //
	property name="isLastPage" setter="false"; //
	property name="lastPage" setter="false"; //
	property name="max" setter="false"; //
	property name="nextPage" setter="false"; //
	property name="offset" setter="false";
	property name="pages" setter="false"; //
	property name="previousPage" setter="false"; //
	property name="search" setter="false";
	property name="sort" setter="false";
	property name="totalItems" setter="false"; //
	property name="totalPages" setter="false"; //

	public function init(required data data){
		variables.data = arguments.data;
		variables.max = 10;		
		setCurrentPage(getFirstPage());
		return this;
	}

	public page function getFirstPage(){
		return getPages()[1];
	}

	public function getHasLastPage(){return hasLastPage();}
	public function getHasNextPage(){return hasNextPage();}
	public function getHasPreviousPage(){return hasPreviousPage();}
	public function getIsLastPage(){return isLastPage();}
	public function getIsFirstPage(){return isFirstPage();}

	public page function getLastPage(){
		return getPages()[getTotalPages()];
	}

	public optional function getNextPage(){

		if(getCurrentPage().equals(getLastPage())){
			return new optional();
		} else {
			return new optional(getPages()[getCurrentPage().getId() + 1]);
		}
	}

	public page[] function getPages(){
		var out = [];
		for(var i=1; i LTE getTotalPages(); i++){

			if(i == 1){
				var start = 1;
				var end = max;
				if(end > getTotalItems()){
					end = getTotalItems();
				}
			} else {
				var start = ((i-1) * variables.max) + 1;
				var end = start + max - 1;
				if(end > getTotalItems()){
					end = getTotalItems();
				}
			}		

			out.append(new page(i, "", start, end));
		}
		return out;
	}

	public optional function getPreviousPage(){
		if(getCurrentPage().equals(getFirstPage())){
			return new optional();
		} else {
			return new optional(getPages()[getCurrentPage().getId() - 1]);
		}
	}

	public function getTotalItems(){
		return variables.data.count();
	}

	public int function getTotalPages(){
		return ceiling(getTotalItems() / variables.max);
	}

	public boolean function hasNextPage(){
		return getNextPage().exists();
	}

	public boolean function hasPreviousPage(){
		return getPreviousPage().exists();
	}

	public boolean function isFirstPage(){
		return getCurrentPage().equals(getFirstPage());
	}

	public boolean function isLastPage(){
		return getCurrentPage().equals(getLastPage());
	}

	/**
	 * Moves the pagination forward to the next page, or the last 
	 * page if it is already there
	 * @return {Function} [description]
	 */
	public void function next(){
		if(getNextPage().exists()){
			setCurrentPage(getNextPage().get());
		}
	}

	public void function previous(){
		if(getPreviousPage().exists()){
			setCurrentPage(getPreviousPage().get());
		}
	}

	private function setCurrentPage(required page page){
		variables.currentPage = arguments.page;
	}

}