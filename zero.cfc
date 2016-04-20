component extends="one" {	

     request._fw1 = {
        cgiScriptName = replaceNoCase(CGI.SCRIPT_NAME,".json",""),
        cgiPathInfo = replaceNoCase(CGI.PATH_INFO,".json",""),
        cgiRequestMethod = CGI.REQUEST_METHOD,
        controllers = [ ],
        requestDefaultsInitialized = false,
        routeMethodsMatched = { },
        doTrace = false,
        trace = [ ]
    };

    request._zero.PathInfo = cgi.path_Info;    
	request._zero.ContentType = listLast(request._zero.PathInfo,".");

	switch(lcase(request._zero.ContentType)){
		case "json":
			request._zero.contentType = "json";			
		break;

		default
			request._zero.contentType = "html";
		break;
	}

	variables.framework = {
		reloadApplicationOnEveryRequest = true,
		defaultItem = "list"
	}

	variables.zero.throwOnNullControllerResult = true;
	variables.zero.argumentCheckedControllers = true;

	variables.framework.resourceRouteTemplates = [
	  { method = 'list', httpMethods = [ '$GET' ] },
	  { method = 'new', httpMethods = [ '$GET', '$POST' ], routeSuffix = '/new' },
	  { method = 'create', httpMethods = [ '$POST' ] },
	  { method = 'read', httpMethods = [ '$GET' ], includeId = true },
	  { method = 'update', httpMethods = [ '$PUT','$PATCH', '$POST' ], includeId = true },
	  { method = 'delete', httpMethods = [ '$DELETE' ], includeId = true }
	];

	
	public function before( rc ){

		if(structKeyExists(this,"request")){
			request( rc );			
		}
	}

	public function after( rc ){

		if(structKeyExists(this,"result")){
			result( rc, ((isNull(request._zero.controllerResult))?: request._zero.controllerResult));			
		}

		if(isNull(request._zero.controllerResult)){
			if(variables.zero.throwOnNullControllerResult){
				throw("The controller #request.action# did not have a return value but it expected one for a json request")
			}
		}

		switch(request._zero.contentType){
			case "json":								

				//If we are allowing null data, then we're going to putput an empty object
				if(isNull(request._zero.controllerResult)){
					renderData("json", {});
				} else {
					renderData("json", request._zero.controllerResult);
				}

			break;

			default:
				if(!isNull(request._zero.controllerResult)){
					structAppend(rc, request._zero.controllerResult);									
				}							
			break;
		}				
	}

	function onRequest(){

		var finalOutput = "";
		savecontent variable="finalOutput" {
			super.onRequest();			
		}

		finalOutput = response(finalOutput);
		writeOutput(finalOutput);
	}

	/*
	Override setupApplicationWrapper() to remove dependency injection which is not needed
	 */
	 private void function setupApplicationWrapper() {
        if ( structKeyExists( request._fw1, "appWrapped" ) ) return;
        request._fw1.appWrapped = true;
        variables.fw1App = {
            cache = {
                lastReload = now(),
                fileExists = { },
                controllers = { },
                routes = { regex = { }, resources = { } }
            },
            subsystems = { },
            subsystemFactories = { }
        };

        /* FRAMEWORK ZERO 
         * Comment out IOC and DI code which is not used by framework zero
         *	 
         */
        // switch ( variables.framework.diEngine ) {
        // case "aop1":
        // case "di1":
        //     var ioc = new "#variables.framework.diComponent#"(
        //         variables.framework.diLocations,
        //         variables.framework.diConfig
        //     );
        //     ioc.addBean( "fw", this ); // alias for controller constructor compatibility
        //     setBeanFactory( ioc );
        //     break;
        // case "wirebox":
        //     if ( isSimpleValue( variables.framework.diConfig ) ) {
        //         // per #363 assume name of binder CFC
        //         var wb1 = new "#variables.framework.diComponent#"(
        //             variables.framework.diConfig, // binder path
        //             variables.framework // properties struct
        //         );
        //         // we do not provide fw alias for controller constructor here!
        //         setBeanFactory( wb1 );
        //     } else {
        //         // legacy configuration
        //         var wb2 = new "#variables.framework.diComponent#"(
        //             properties = variables.framework.diConfig
        //         );
        //         wb2.getBinder().scanLocations( variables.framework.diLocations );
        //         // we do not provide fw alias for controller constructor here!
        //         setBeanFactory( wb2 );
        //     }
        //     break;
        // case "custom":
        //     var ioc = new "#variables.framework.diComponent#"(
        //         variables.framework.diLocations,
        //         variables.framework.diConfig
        //     );
        //     setBeanFactory( ioc );
        //     break;
        // }

        // this will recreate the main bean factory on a reload:
        internalFrameworkTrace( 'setupApplication() called' );
        setupApplication();
		application[variables.framework.applicationKey] = variables.fw1App;

	}

	private void function doController( struct tuple, string method, string lifecycle ) {
        var cfc = tuple.controller;
        if ( structKeyExists( cfc, method ) ) {
            try {
                internalFrameworkTrace( 'calling #lifecycle# controller', tuple.subsystem, tuple.section, method );
                // request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );
                // 
                if(arguments.lifecycle == "item"){

                	if(variables.zero.argumentCheckedControllers){
                		var args = getMetaDataFunctionArguments(cfc, method);
                		// writeDump(args);
                		// abort;
                		argsToPass = {};

                		request.context.headers = request._fw1.headers;
                		
                		for(var arg in args){
                			if(structKeyExists(request.context,arg.name)){
                				argsToPass[arg.name] = request.context[arg.name];
                			}                			     
                		}
	                	request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = argsToPass)' );                		
                	} else {
                		request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );	
                	}
	                
            	} else {
            		request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );
            	}

            } catch ( any e ) {
                setCfcMethodFailureInfo( cfc, method );
                rethrow;
            }
        } else if ( structKeyExists( cfc, 'onMissingMethod' ) ) {
            try {
                internalFrameworkTrace( 'calling #lifecycle# controller (via onMissingMethod)', tuple.subsystem, tuple.section, method );
                request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, method = lifecycle, headers = request._fw1.headers )' );                
            } catch ( any e ) {
                setCfcMethodFailureInfo( cfc, method );
                rethrow;
            }
        } else {
            internalFrameworkTrace( 'no #lifecycle# controller to call', tuple.subsystem, tuple.section, method );
        }
    }

    private function getMetaDataFunctionArguments(required cfc, required method){
    	var cfc = arguments.cfc;
    	var method = arguments.method;
    	var metaData = getMetaData(cfc);
    	// writeDump(metaData);
    	// abort;
    	for(var func in metaData.functions){
    		if(func.name == method){
    			return func.parameters;
    		}
    	}

    	throw("Did not expect to get to this point, controller method #method# does not exist. framework zero");
    }

}