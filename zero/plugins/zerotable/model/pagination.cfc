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

	public optional function findPageById(required numeric id){
		var pages = this.getPages();
		if(arguments.id > pages.len()){
			return new Optional();
		} else {
			return new optional(pages[arguments.id]);
		}		
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
		for(var tryPage in getPages()){
			if(tryPage.equals(arguments.page)){
				tryPage.setIsCurrentPage(true);
			} else {
				tryPage.setIsCurrentPage(false);
			}
		}	
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

	public page[] function getPages(totalPages=this.getTotalPages(),
									totalItems=this.getTotalItems(),
									offset=variables.offset,
									max=variables.max) {
		/**
		 * Building the pages takes a long time, so we cache this value so that subsequent
		 * requests to getPages returns the existing array		 
		 */
		if(structKeyExists(variables,"zeroCachePages")){
			return variables.zeroCachePages;
		} else {

			var out = [];

			var startIndex = 1;
			var endIndex = max;
			
			var isCurrentPage = false;

			for(var i=0; i LT arguments.totalPages; i++){

				pageOffset = i * max;
				startIndex = (i * max) + 1;
				endIndex = (i + 1) * max;

				if(offset >= pageOffset and offset < endIndex){					
					isCurrentPage = true;
				} else {
					isCurrentPage = false;
				}			

				out.append(new page(id=i+1,
									link=variables.queryString.setValues({"offset":pageOffset}).get(), 
									startIndex=startIndex, 
									endIndex=endIndex, 
									isCurrentPage=isCurrentPage)
				);
			}		
			// writeDump(out);
			variables.zeroCachePages = out;
			return out;
		}
		
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
				diff = abs(half - min) - 1;
				min = 1;												
			}

			// writeDump(min);
			var max = getCurrentPage().getId() + half + diff;
			// writeDump(max);
			if(max > pages.len()){
				var diff = abs(max - pages.len());
				max = pages.len();


				min = min - half;
				if(min <= 0){
					min = 1;
				}
			}			

			try {

				var out = [];
				for(var i=min; i LTE max; i++){
					if(out.len() == variables.showMaxPages){
						break;
					}
					out.append(pages[i]);
				}

			}catch(any e){
				
				writeDump(min);
				writeDump(max);
				writeDump(pages.len());
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

	public numeric function getTotalPages(totalItems=this.getTotalItems(), max=variables.max) cachedWithin="request" {
		var ceiling = ceiling(arguments.totalItems / arguments.max);
		if(ceiling == 0){
			ceiling = 1;
		}		
		return ceiling;
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
			// writeDump(getNextPage().get());
			this.setCurrentPage(getNextPage().get());
		}
	}

	public void function previous(){
		if(getPreviousPage().exists()){
			setCurrentPage(getPreviousPage().get());
		}
	}

	public function toJson(){

		var out = {
			"current_page":pageToJson(getcurrentPage()),
			"dir":getdir(),
			"first_page":pageToJson(getfirstPage()),
			"has_next_page":gethasNextPage(),
			"has_previous_page":gethasPreviousPage(),
			"is_first_page":getisFirstPage(),
			"is_last_page":getisLastPage(),
			"last_page":pageToJson(getlastPage()),
			"max":getmax(),
			"next_page":pageToJson(getnextPage()),
			"offset":getoffset(),
			// "pages":pagesToJson(getpages()),
			"previous_page":pageToJson(getpreviousPage()),
			"search":getsearch(),
			"sort":getsort(),
			"summary_pages":pagesToJson(getsummaryPages()),
			"total_items":gettotalItems(),
			"total_pages":gettotalPages(),
		}

		return out;
	}

	private function pageToJson(required any page){
		if(isInstanceOf(arguments.page, "optional")){
			if(page.exists()){
				var page = page.get();				
			} else {
				return "";
			}
		}		
		return page.toJson();
	}

	private array function pagesToJson(required array pages){
		var out = [];
		for(var page in pages){
			out.append(page.toJson())
		}
		return out;
	}

}