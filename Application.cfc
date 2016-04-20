component extends="zero" {
	
	
	variables.zero = {
		//Whether controllers should return a result
		throwOnNullControllerResult = true,
		//Whether the arguments on the controller are checked and only those specific keys passed to it
		argumentCheckedControllers = true
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
	public any function result( rc, result ){				
		return result;		
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

	function onError(){
		writeDump(arguments);

	}

}
