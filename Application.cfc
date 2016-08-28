component extends="zero" {	
	
	this.name="zero";
	/*
	Zero only have a couple of configurable options. listed below. The rest of the confirugation
	is via overrides of FW/1 in the zero.cfc. You can specify any FW/1 settings you deem necessary.	
	 */	
	variables.zero = {
		/*
		Whether controllers should allow null responses. In Zero, it expects controllers
		to return the response that is passed onto the view.
		 */
		throwOnNullControllerResult = true,

		/*
		Whether the arguments on the controller are checked and only those specific keys
		passed to it. In Zero, the entire RC scope is not passed around. Only the specific keys 
		that the controller is looking for is passed to it. This allows the internals
		of the controller to more easily work with what it expects, instead of a huge
		struct of data which changing elements may have side effects.
		 */
		argumentCheckedControllers = true,

		/*
		Whether to output errors other than of the type zeroController when making Json requests. Set this to true in development environments 
		but false in production environments, because it may be a security risk to expose Lucee
		errors.		
		 */
		outputNonControllerErrors = false,

	}

	/*
	For your reference, thesea are the fw/1 settings which are overrideen by Zero.

	variables.framework = {
		reloadApplicationOnEveryRequest = true, //These setting causes endless strife for new users, because it caches controller data when they do not expect it. 
		defaultItem = "list" //Reset the default method from 'default' to 'list', to support our resource routes. List is more common for what the default method does
	} 
	
	//Change the names of the controller routes to match CRUD. After all, these map to CRUD actions,
	//I find changing the names is confusing to new users
	variables.framework.resourceRouteTemplates = [
	  { method = 'list', httpMethods = [ '$GET' ] },
	  { method = 'new', httpMethods = [ '$GET', '$POST' ], routeSuffix = '/new' },
	  { method = 'create', httpMethods = [ '$POST' ] },
	  { method = 'read', httpMethods = [ '$GET' ], includeId = true },
	  { method = 'update', httpMethods = [ '$PUT','$PATCH', '$POST' ], includeId = true },
	  { method = 'delete', httpMethods = [ '$DELETE' ], includeId = true }
	];
	 */
	
	/**
	 * Will be given the routes from Framework zero. You can append or prepend additional routes
	 * @param  {array} array routes        The array of routes that Zero will be parsing
	 * @return {void}       
	 */
	public void function setupRoutes(array routes){		
		
	}


	/**
	 * Used to manipulate request variables before they are passed to controllers.
	 * @param  {struct} rc All of the URL and FORM variable put into one structure. RC is a reference to request.context
	 * @return {Struct}    The result of the RC is then passed onto the controller for this call
	 */
	public struct function request( rc ){
		return rc;
	}

	/**
	 * Called after controller execution and before the view. Here you 
	 * can make any additional changes if necessary to inject more values
	 * for the view.
	 * 
	 * @rc  {struct} rc the request of the request context and 
	 * @result  {any} the result of the call to the controller
	 * @return {any}    The modified result to be used by the view
	 */
	public any function result( controllerResult ){						
		return controllerResult;
	}

	/**
	 * Receives the final respons that is going to be returned to the client. This is the HTML
	 * or text encoded JSON that will be returned. This function can be used to 
	 * manipulate optionally manipulate the final text response
	 *
	 * 
	 * @param  {string} string response  the final output to be returned.
	 * @return {string} Must return a string for the response to complete;
	 */
	public string function response( string response){		
		return response;		
	}

}
