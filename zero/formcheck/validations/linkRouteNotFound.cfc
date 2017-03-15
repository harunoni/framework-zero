/**
*/
component implements="validation,linkElement,routesFunc,routes" {
	public function init(required routesFunc, required linkElement, required array routes){

		var href = linkElement.attr("href");
		var href = listFirst(href, "?");

		if(href == "" or href == "/" or href == "##"){
			return;
		}

		result = routesFunc(href, routes, "GET");
		if(result.matched){

		} else {
			throw("Could not find the route for the a link: #href#");
		}
		return this;
	}
}