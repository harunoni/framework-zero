/**
 * Represents a pagination
*/
component accessors="true" {

	property name="currentPage"; //
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
	property name="summaryPages" setter="false";
	property name="totalItems" setter="false"; //
	property name="totalPages" setter="false"; //


	public function init(required data data, required numeric max=10, required numeric offset, required queryString queryString, required numeric showMaxPages){
		variables.data = arguments.data;
		variables.max = arguments.max;
		variables.offset = arguments.offset;
		variables.queryString = arguments.queryString;

		//Remove variables from the query string which are never used in pagination
		variables.queryString.delete("edit_col")
							 .delete("edit_id");
							 
		variables.showMaxPages = arguments.showMaxPages;
		// variables.currentPageId = arguments.currentPageId;
		// setCurrentPage(getFirstPage());
		return this;
	}

	public page function getFirstPage(){
		return getPages()[1];
	}

	public page function getCurrentPage(){
		var pages = getPages();
		for(var page in pages){
			if(page.getIsCurrentPage()){
				return page;
			}
		}
		throw("no page was the current page, this was not expected");
	}		

	public function getHasLastPage(){return hasLastPage();}
	public function getHasNextPage(){return hasNextPage();}
	public function getHasPreviousPage(){return hasPreviousPage();}
	public function getIsLastPage(){return isLastPage();}
	public function getIsFirstPage(){return isFirstPage();}

	public page function getLastPage(){
		return getPages().last();
	}

	public void function setCurrentPage(required page page){	
		// abort;	
		variables.offset = arguments.page.getStartIndex();
	}

	// public function setCurrentPage(){
	// 	return "foo";
	// }

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

			if(variables.offset >= start and variables.offset <= end){
				var isCurrentPage = true;
			} else {
				var isCurrentPage = false;
			}
			// writeDump(isCurrentPage);		


			out.append(new page(id=i,
								link=variables.queryString.setValues({"offset":start}).get(), 
								startIndex=start, 
								endIndex=end, 
								isCurrentPage=isCurrentPage)
			);
		}		

		return out;
	}

	/**
	 * Returns a subset of the pages to display in the view which is more user friendly
	 * when there are a lot of pages to return
	 * @return {[type]} [description]
	 */
	public page[] function getSummaryPages(){
		var pages = getPages();
		var out = [];
		if(variables.showMaxPages > 0){
			var half = int(variables.showMaxPages / 2);
			// writeDump(half);
			var min = getCurrentPage().getId() - half;
			// writeDump(min);
			// abort;
			var diff = 1;
			if(min <= 0){
				var diff = abs(min) + 2;
				min = 1;
			}

			var max = getCurrentPage().getId() + half + diff;
			if(max >= getTotalPages()){
				var diff = abs(max - getTotalPages());
				max = getTotalPages();

				min = min - diff;
				if(min <= 0){
					min = 1;
				}
			}			


			try {
				var out = pages.slice(min, max-min);							
			}catch(any e){
				
				writeDump(min);
				writeDump(max);
				writeDump(getTotalPages());
				writeDump(pages);
				writeDump(e);
				abort;
			}
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

	public numeric function getTotalPages(){
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
			this.setCurrentPage(getNextPage().get());
		}
	}

	public void function previous(){
		if(getPreviousPage().exists()){
			setCurrentPage(getPreviousPage().get());
		}
	}

}