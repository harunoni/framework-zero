component extends="one" {	

	copyCGI = duplicate(CGI);	
	
	/*
	Global framework rewrite of the request scope. Allows mimicing HTML 5 
	nested form feature, which is not currently supported by Internet Explorer.
	Will introspect the form data and override the copied CGI information
	with the route in the form so what fw/1 routes pick the intended controller
	 */	
	if(structKeyExists(form,"zero_form")){
		zeroForms = listToArray(form.zero_form);
		for(zeroFormName in zeroForms){			
			if(structKeyExists(form,zeroFormName)){
				formgroup = duplicate(form[zeroFormName]);			
				if(structKeyExists(formgroup,"submit")){
					actionPathInfo = replaceNoCase(formgroup.action, copyCGI.SCRIPT_NAME, "");
					copyCGI.path_info = actionPathInfo;	
					copyCGI.request_method = formgroup.method;						
					structClear(form);
					structAppend(form,formgroup.data);			
				}							
			}
		}
	}
	
     request._fw1 = {
        cgiScriptName = replaceNoCase(copyCGI.SCRIPT_NAME,".json",""),
        cgiPathInfo = replaceNoCase(copyCGI.PATH_INFO,".json",""),
        cgiRequestMethod = copyCGI.REQUEST_METHOD,
        controllers = [ ],
        requestDefaultsInitialized = false,
        routeMethodsMatched = { },
        doTrace = false,
        trace = [ ]
    };
	
    request._zero.PathInfo = copyCGI.path_Info;    
	request._zero.ContentType = listLast(request._zero.PathInfo,".");

	switch(lcase(request._zero.ContentType)){
		case "json":
			request._zero.contentType = "json";			
		break;

		default:
			request._zero.contentType = "html";
		break;
	}

	
	this.clientManagement = true;
	this.clientStorage = "cookie";

	variables.zero.throwOnNullControllerResult = true;
	variables.zero.argumentCheckedControllers = true;

	variables.framework.SESOmitIndex = true;
	variables.framework.generateSES = true;

	/*
		This is provided for illustration only - YOU SHOULD NOT USE THIS IN
		A REAL PROGRAM! ONLY SPECIFY THE DEFAULTS YOU NEED TO CHANGE!
	variables.framework = {
		// the name of the URL variable:
		action = 'action',
		// whether or not to use subsystems:
		usingSubsystems = false,
		// default subsystem name (if usingSubsystems == true):
		defaultSubsystem = 'home',
		// default section name:
		defaultSection = 'main',
		// default item name:
		defaultItem = 'default',
		// if using subsystems, the delimiter between the subsystem and the action:
		subsystemDelimiter = ':',
		// if using subsystems, the name of the subsystem containing the global layouts:
		siteWideLayoutSubsystem = 'common',
		// the default when no action is specified:
		home = defaultSubsystem & ':' & defaultSection & '.' & defaultItem,
		-- or --
		home = defaultSection & '.' & defaultItem,
		// the default error action when an exception is thrown:
		error = defaultSubsystem & ':' & defaultSection & '.error',
		-- or --
		error = defaultSection & '.error',
		// the URL variable to reload the controller/service cache:
		reload = 'reload',
		// the value of the reload variable that authorizes the reload:
		password = 'true',
		// debugging flag to force reload of cache on each request:
		reloadApplicationOnEveryRequest = false,
		// whether to force generation of SES URLs:
		generateSES = false,
		// whether to omit /index.cfm in SES URLs:
		SESOmitIndex = false,
		// location used to find layouts / views:
		base = ... relative path from Application.cfc to application files ...
		// either CGI.SCRIPT_NAME or a specified base URL path:
		baseURL = 'useCgiScriptName',
		// location used to find controllers / services:
		// cfcbase = essentially base with / replaced by .
		// list of file extensions that FW/1 should not handle:
		unhandledExtensions = 'cfc',
		// list of (partial) paths that FW/1 should not handle:
		unhandledPaths = '/flex2gateway',
		// flash scope magic key and how many concurrent requests are supported:
		preserveKeyURLKey = 'fw1pk',
		maxNumContextsPreserved = 10,
		// set this to true to cache the results of fileExists for performance:
		cacheFileExists = false,
		// change this if you need multiple FW/1 applications in a single CFML application:
		applicationKey = 'framework.one',
        // change this if you want a different dependency injection engine:
        diEngine = 'di1',
        // change this if you want different locations to be scanned by the D/I engine:
        diLocations = 'model,controllers',
        // optional configuration for your dependency injection engine:
        diConfig = { },
        // routes (for fancier SES URLs) - see the documentation for details:
        routes = [ ],
        routesCaseSensitive = true
	};
	*/
	variables.framework = {
		reloadApplicationOnEveryRequest = true,
		defaultItem = "list"
	}

	variables.framework.resourceRouteTemplates = [
	  { method = 'list', httpMethods = [ '$GET' ] },
	  { method = 'new', httpMethods = [ '$GET', '$POST' ], routeSuffix = '/new' },
	  { method = 'create', httpMethods = [ '$POST' ] },
	  { method = 'read', httpMethods = [ '$GET' ], includeId = true },	  
	  { method = 'read', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/read' },	  
	  { method = 'update', httpMethods = [ '$PUT','$PATCH', '$POST' ], includeId = true },
	  { method = 'delete', httpMethods = [ '$DELETE' ], includeId = true },
	  { method = 'delete', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/delete' }
	];

	loadControllers();
	/**
	 * Createa a default RESTful route for each controller present
	 * in the controllers folder 
	 * @return {array} The routes created by this function
	 */
	private array function loadControllers(){
		
		variables.framework.routes = []
		var controllers = directoryList(path=expandPath("controllers"), filter="*.cfc");
		// writeDump(controllers);
		// abort;
		for(var controller in controllers){
			file = getFileFromPath(controller);
			name = listFirst(file, ".");
			variables.framework.routes.append({ "$RESOURCES" = { resources = name} })
		}
		return variables.framework.routes;
	}
	
	public function before( rc ){

		//If the user's Application CFC has the request method, then we call it
		if(structKeyExists(this,"request")){
			request( rc );			
		}
	}

	public function buildURL(value){
		var value = super.buildURL(value);
		value = replaceNoCase(value,":","/");
		return value;
	}

	public function onError(error, event){
		
		switch(request._zero.contentType){
			case "json":				

				if(!error.errorCode == "0"){
					var errorcode = error.errorCode
				} else {
					var errorcode = "500";
				}

				var out = {
					"success":false,
					"message":error.message,
					"status_code":errorCode,
				}				
				
				header statuscode="#errorCode#";				
				writeOutput(serializeJson(out));
				abort;
			break;

			case "html":				
				super.onError(error, event);
			break;
		}
	}

	public function after( rc, headers, controllerResult ){		

		if(isNull(request._zero.controllerResult)){
			if(variables.zero.throwOnNullControllerResult){
				throw("The controller #request.action# #request.item# did not have a return value but it expected one for a json request")
			}
		}

		//If the user's Application CFC has the request method, then we call it
		if(structKeyExists(this,"result")){
			request._zero.controllerResult = result( controllerResult );			
		}

		structAppend(rc, client);

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

				if(structKeyExists(rc,"goto")){

					if(structKeyExists(form,"preserve_response")){
						// writeDump(now());
						// abort;
						try {
							client[form.preserve_response] = request._zero.controllerResult;							
						} catch(any e){
							writeDump(now());
							writeDump("Error saving cooking data");
						}
					}

					var goto = rc.goto;
					rc = {}
					if(!isNull(request._zero.controllerResult)){
						for(var key in request._zero.controllerResult){
							rc[key] = request._zero.controllerResult[key];
						}					
					}

					if(goto contains ":"){
						writeDump(goto);
						variable = reReplaceNoCase(goto, "(.*):([A-Zaz\.]*)", "\2");
						// writeDump(variable);
						// writeDump(rc);
						// abort;
						tryNull = evaluate("isNull(rc.#variable#)");
						if(tryNull){
							throw("Value not found");
						} else {
							value = getVariable("rc.#variable#");
							goto = replaceNoCase(goto, ":#variable#", value);
						}

					}					
					if(structKeyExists(client,"goto")){
						structDelete(client,"goto");//Remove the goto so that it is not an infinite redirect						
					}


					location url="#goto#" addtoken="false";
				}				
				
				//Clear out the RC scope because only the result from the controller will be passed
				//to the view
				rc = {}
				if(!isNull(request._zero.controllerResult)){
					for(var key in request._zero.controllerResult){
						rc[key] = request._zero.controllerResult[key];
					}					
				}
				request.context = rc;		

			break;			
		}	
		return controllerResult;					
	}	

	function onRequest(){

		var finalOutput = "";
		savecontent variable="finalOutput" {
			super.onRequest();			
		}

		finalOutput = response(finalOutput);
		writeOutput(finalOutput);

		//Clear out the client at the end of the request
		client = {};
		structClear(client);		
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

	private boolean function controllerHasFunction(cfc, funcName){

		var functions = getMetaData(cfc).functions;
		for(var func in functions){
			if(func.name == funcName){
				return true;
			}
		}

		return false;
	}

	private void function doController( struct tuple, string method, string lifecycle ) {
        var cfc = tuple.controller;


        getArgumentsToPass = function(){
	    	var args = getMetaDataFunctionArguments(cfc, method);
			// writeDump(args);
			// abort;
			argsToPass = {};

			request.context.headers = request._fw1.headers;
			
			for(var arg in args){
				
				if(structKeyExists(request.context,arg.name)){
					argsToPass[arg.name] = request.context[arg.name];
				}    

				if(structKeyExists(client,arg.name)){                			
					argsToPass[arg.name] = client[arg.name];
				}              			     
			}
	    }


        if ( structKeyExists( cfc, method ) ) {
            try {
                internalFrameworkTrace( 'calling #lifecycle# controller', tuple.subsystem, tuple.section, method );
                // request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );
                // 
                if(arguments.lifecycle == "item"){

                	if(controllerHasFunction(cfc, "request")){
                		evaluate( 'cfc.request( rc = request.context, headers = request._fw1.headers)' );
                	}

                	if(variables.zero.argumentCheckedControllers){                		
	                	request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = getArgumentsToPass)' );                		
                	} else {
                		request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );	
                	}

                	if(controllerHasFunction(cfc, "result")){
                		if(isNull(request._zero.controllerResult)){
							if(variables.zero.throwOnNullControllerResult){								
								throw("The controller #request.action# #request.item# did not have a return value but it expected one for a json request")
							}
						} else {            				
                			evaluate( 'cfc.result( request._zero.controllerResult )' );
						}
                	}
	                
            	} else {

            		/* Zero overrides what happens with after methods to pass in the result of the controller call as
            		an additional parameter
            		*/
            		if(method == "after"){

            			request._zero.controllerLifecycleResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers, controllerResult = request._zero.controllerResult)' );

            			if(isNull(request._zero.controllerLifecycleResult)){
							if(variables.zero.throwOnNullControllerResult){								
								throw("The controller #request.action# #request.item# after() did not have a return value but it expected one for a json request")
							}
						} else {
            				request._zero.controllerResult = request._zero.controllerLifecycleResult							
						}
            		} else {
            			request._zero.controllerLifecycleResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );
            		}
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


     private void function setupSubsystemWrapper( string subsystem ) {
        if ( !len( subsystem ) ) return;
        lock name="fw1_#application.applicationName#_#variables.framework.applicationKey#_subsysteminit_#subsystem#" type="exclusive" timeout="30" {
            if ( !isSubsystemInitialized( subsystem ) ) {
                getFw1App().subsystems[ subsystem ] = now();
                // Application.cfc does not get a subsystem bean factory!
                if ( subsystem != variables.magicApplicationSubsystem ) {
                    var subsystemConfig = getSubsystemConfig( subsystem );
                    var diEngine = structKeyExists( subsystemConfig, 'diEngine' ) ? subsystemConfig.diEngine : variables.framework.diEngine;
                    if ( diEngine == "di1" || diEngine == "aop1" ) {
                        // we can only reliably automate D/I engine setup for DI/1 / AOP/1
                        var diLocations = structKeyExists( subsystemConfig, 'diLocations' ) ? subsystemConfig.diLocations : variables.framework.diLocations;
                        var locations = isSimpleValue( diLocations ) ? listToArray( diLocations ) : diLocations;
                        var subLocations = "";
                        for ( var loc in locations ) {
                            var relLoc = trim( loc );
                            // make a relative location:
                            if ( len( relLoc ) > 2 && left( relLoc, 2 ) == "./" ) {
                                relLoc = right( relLoc, len( relLoc ) - 2 );
                            } else if ( len( relLoc ) > 1 && left( relLoc, 1 ) == "/" ) {
                                relLoc = right( relLoc, len( relLoc ) - 1 );
                            }
                            if ( usingSubsystems() ) {
                                subLocations = listAppend( subLocations, variables.framework.base & subsystem & "/" & relLoc );
                            } else {
                                subLocations = listAppend( subLocations, variables.framework.base & variables.framework.subsystemsFolder & "/" & subsystem & "/" & relLoc );
                            }
                        }
                        if ( len( sublocations ) ) {
                            // var diComponent = structKeyExists( subsystemConfig, 'diComponent' ) ? subsystemConfig : variables.framework.diComponent;
                            // var cfg = structKeyExists( subsystemConfig, 'diConfig' ) ?
                            //     subsystemConfig.diConfig : structCopy( variables.framework.diConfig );
                            // cfg.noClojure = true;
                            // var ioc = new "#diComponent#"( subLocations, cfg );
                            // ioc.setParent( getDefaultBeanFactory() );
                            // setSubsystemBeanFactory( subsystem, ioc );
                        }
                    }
                }

                internalFrameworkTrace( 'setupSubsystem() called', subsystem );
                setupSubsystem( subsystem );
            }
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