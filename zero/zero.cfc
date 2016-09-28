import serializer;
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

					originalForm = duplicate(form);
					structClear(form);
					structAppend(form,formgroup.data);									
					if(formgroup.preserveParentInputs){
						structAppend(form, originalForm);	
					} 				
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
	this.scriptProtect = "all";

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
		defaultItem = "list",
		usingSubsystems:false,
		SESOmitIndex = true,
		generateSES = true
	}

	variables.zero.argumentModelValueObjectPath = "model";
	variables.zero.throwOnFirstArgumentError = variables.zero.throwOnFirstArgumentError ?: false;

	variables.framework.resourceRouteTemplates = [
	  { method = 'validate', httpMethods = [ '$POST' ], routeSuffix = '/validate' },

	  { method = 'list', httpMethods = [ '$GET' ] },
	  { method = 'list', httpMethods = [ '$POST' ], routeSuffix = '/list' },
	  { method = 'list', httpMethods = [ '$GET' ], routeSuffix = '/list' },

	  { method = 'new', httpMethods = [ '$POST' ], routeSuffix = '/new' },
	  { method = 'new', httpMethods = [ '$GET' ], routeSuffix = '/new' },

	  { method = 'edit', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/edit' },
	  { method = 'edit', httpMethods = [ '$GET' ], includeId = true, routeSuffix = '/edit' },
	  
	  { method = 'create', httpMethods = [ '$POST' ], routeSuffix = '/create' },
	  { method = 'create', httpMethods = [ '$POST' ] },
	  
	  { method = 'read', httpMethods = [ '$GET' ], includeId = true },	  
	  { method = 'read', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/read' },	  
	  
	  { method = 'update', httpMethods = [ '$PUT','$POST' ], includeId = true },
	  { method = 'update', httpMethods = [ '$PUT','$POST' ], routeSuffix = '/update' },
	  
	  { method = 'delete', httpMethods = [ '$DELETE' ], includeId = true },
	  { method = 'delete', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/delete' },

	];
	
	public function collectValues(required struct args){
		out = {};
		for(var arg in args){

			if(!isNull(args[arg])){
				if(isInstanceOf(args[arg], "valueObject")){
					out[arg] = args[arg].toString();				
				} else {
					out[arg] = args[arg];
				}				
			}
		}
		return out;
	}
	

	public function after( rc, headers, controllerResult ){		
		writeLog(file="zero_trace", text="start after()");
		// writeDump(request._zero.controllerResult);
		// writeDump(rc);
		// abort;

		if(isNull(request._zero.controllerResult)){
			if(variables.zero.throwOnNullControllerResult){
				throw("The controller #request.action# #request.item# did not have a return value but it expected one for a json request")
			}
		}

		//If the user's Application CFC has the request method, then we call it
		if(structKeyExists(this,"result")){
			request._zero.controllerResult = result( controllerResult );
		}

		if(isComponentOrArrayOfComponents(request._zero.controllerResult)){	
			try {
				request._zero.controllerResult = entityToJson(request._zero.controllerResult)				
			}catch(any e){
				writeDump(request._zero.controllerResult);
				writeDump(e);
				abort;
			}
		}	

		try {
			request._zero.controllerResult = this.serialize(request._zero.controllerResult);			
		}catch(any e){
			writeDump(request._zero.controllerResult);
			writeDump(e);
			abort;
		}

		var recurseAndLowerCaseTheKeys = function(struct){
			for(var key in arguments.struct){
				// arguments.struct["#lcase(key)#"] = arguments.struct[key];				
				
				if(isNull(arguments.struct[key])){
					temp = nullValue();
				} else {
					var temp = duplicate(arguments.struct[key]);					
				}

				// if(!isNull(temp) and isComponentOrArrayOfComponents(temp)){
				// 	temp = this.serialize(temp);
				// 	// throw("Could not continue because the controller result is a component and not a simple array or struct. This could be an error in the data returned from the controller, or Zero was not able to serialize your result properly.");
				// }

				arguments.struct.delete(key);
				arguments.struct.insert("#lcase(camelToUnderscore(key))#", temp?:nullValue(), true);
				
				if(!isNull(arguments.struct[key]) AND isStruct(arguments.struct[key])){
					recurseAndLowerCaseTheKeys(arguments.struct[key]);
				}
			}
			return struct;
		} 

		recurseAndLowerCaseTheKeys(request._zero.controllerResult);
		
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


				if(request._zero.keyExists("zeroFormState")){
					if(CGI.request_method contains "POST"){
						request._zero.zeroFormState.setFormData(form);
						
						if(request._zero.argumentErrors.isEmpty()){				
							
							if(rc.keyExists("start_over")){
								request._zero.zeroFormState.start();
							} else if(rc.keyExists("first_step")){
								request._zero.zeroFormState.first();
							} else if(rc.keyExists("move_forward")){
								request._zero.zeroFormState.moveForward();
							} else if(rc.keyExists("move_backward")){								
								request._zero.zeroFormState.moveBackward();								
							} else if(rc.keyExists("current_step")){
								request._zero.zeroFormState.completeStep(rc.current_step);								
							} else {
								request._zero.zeroFormState.start();
							}

							if(rc.keyExists("form_state_clear_form")){								
								request._zero.zeroFormState.clearFormData();
							}
						}						
					}
				}			

				if(rc.keyExists("goto_fail")){
					if(request._zero.controllerResult.keyExists("success") and request._zero.controllerResult.success == false){
						rc.goto = rc.goto_fail;
						form.preserve_response = true;						
						form.preserve_request = true;
						if(form.keyExists("preserve_form")){
							structDelete(form,"preserve_form");
						}
					}
				}

				//Setup an alias to goto
				if(rc.keyExists("goto_after")){
					rc.goto = rc.goto_after;
				}

				if(rc.keyExists("goto")){					

					if(structKeyExists(form,"preserve_response")){
						if(isBoolean(form.preserve_response)){
							var prefix = "preserve_response";
						} else if(trim(form.preserve_response) == ""){
							var prefix = "preserve_response";
						} else {
							var prefix = "preserve_response.#form.preserve_response#";
						}
						// writeDump(prefix);
						
						var formKeys = flattenDataStructureForCookies(data=request._zero.controllerResult, prefix=prefix, ignore="delete_key,goto,preserve_form,submit_overload,redirect,map,preserve_response");						
						cookie.append(formKeys);						
					}

					if(form.keyExists("preserve_form")){

						if(trim(form.preserve_form) == ""){
							form.preserve_form = true;
						}

						if(!isBoolean(form.preserve_form)){
							throw("preserve_form must either be true or false");
						}

						if(form.preserve_form){
							var formKeys = flattenDataStructureForCookies(data=form, prefix="preserve_form", ignore="delete_key,goto,preserve_form,submit_overload,redirect,map,preserve_response");
							cookie.append(formKeys);													
						}
					}


					if(form.keyExists("preserve_request")){						
						var formKeys = flattenDataStructureForCookies(data=form, prefix="preserve_request.form", ignore="delete_key,goto,preserve_form,submit_overload,redirect,map,preserve_response,preserve_request");
						cookie.append(formKeys);

						var formKeys = flattenDataStructureForCookies(data=url, prefix="preserve_request.url", ignore="delete_key,goto,preserve_form,submit_overload,redirect,map,preserve_response,preserve_request");
						cookie.append(formKeys);									
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
						tryNull = evaluate("isNull(rc.#variable#)");
						if(tryNull){
							throw("Value not found");
						} else {
							value = getVariable("rc.#variable#");
							goto = replaceNoCase(goto, ":#variable#", value);
						}
					}	

					// if(structKeyExists(client,"goto")){
					// 	structDelete(client,"goto");//Remove the goto so that it is not an infinite redirect						
					// }

					// header name="Cache-Control" value="max-age=120";
					doTrace(rc, "RC after() redirect");
					doTrace(FORM, "FORM after() redirect");
					doTrace(cookie, "COOKIE after() redirect");
					writeLog(file="zero_trace", text="do after() redirect");
					// writeDump(now());
					// abort;
					request._zero.zeroClient.persist();
					location url="#goto#" addtoken="false" statuscode="303";
				}								

				/*
				To protect against XSS attacks in HTML output, we escape all strings that are the result from the controller
				 */
				if(variables.zero.encodeResultForHTML ){
					request._zero.controllerResult = encodeResultFor("HTML", request._zero.controllerResult);					
				}

				//Clear out the RC scope because only the result from the controller will be passed
				//to the view
				rc = {}
				if(!isNull(request._zero.controllerResult)){
					for(var key in request._zero.controllerResult){
						rc[key] = request._zero.controllerResult[key];
					}					
				}
				rc.client = client;

				if(request._zero.keyExists("zeroFormState")){
					// rc.form_state = recurseAndLowerCaseTheKeys(request._zero.zeroFormState.getFormCache());
					rc.form_state = this.serialize(request._zero.zeroFormState);
				}

				if(!request._zero.argumentErrors.isEmpty()){
					rc.errors = request._zero.argumentErrors;
				}

				request.context = rc;

				request._zero.zeroClient.persist();				
			break;			
		}	
		writeLog(file="zero_trace", text="end zero.after()");
		return controllerResult;					
	}	
	
	public function before( rc ){
		writeLog(file="zero_trace", text="start before()");
		doTrace(rc, "RC before()");



		if(url.keyExists("clearClient")){
			structClear(client);
			client = {};			
		}

		if(rc.keyExists("form_state") and rc.keyExists("preserve_form")){
			throw("Do not use form_state and preserve_form together.")
		}

		// if(CGI.request_method == "POST"){
		// 	if(cookie.keyExists("CSRF_TOKEN")){
		// 		if(!form.keyExists("CSRF_TOKEN")){
		// 			throw("Unauthorized Request", 401);
		// 		} else {
		// 			if(form.csrf_token != cookie.csrf_token){
		// 				throw("Unauthorized Request", 401);
		// 			} else {
		// 			}
		// 		}				
		// 		structDelete(cookie,"CSRF_TOKEN");
		// 	}			
		// } else {
		// 	structDelete(cookie,"CSRF_TOKEN");
		// }

		/*
		Cookie structures are saved as individual keys, so need to use structKeyTranslate
		to get them back into a structure
		 */
		// cookies = duplicate(cookie);
		// structKeyTranslate(cookies, true, true);		
		cookies = expandFlattenedData(cookie);
		// writeDump(cookies);
		// abort;

		if(cookies.keyExists("preserve_form")){
			form.append(cookies.preserve_form);
			rc.Append(cookies.preserve_form);
			var deleteCookies = flattenDataStructureForCookies(data=cookies.preserve_form, prefix="preserve_form", ignore=[]);									
			for(var cook in deleteCookies){
				header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";
			}
		}


		if(cookies.keyExists("preserve_request")){
			// writeDump(cookie);
			// writeDump(getHTTPRequestData());	
			// abort;
			if(cookies.preserve_request.keyExists("form")){
				form.append(cookies.preserve_request.form);
				rc.Append(cookies.preserve_request.form);
				var deleteCookies = flattenDataStructureForCookies(data=cookies.preserve_request.form, prefix="preserve_request.form", ignore=[]);					
				for(var cook in deleteCookies){
					header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";					
					structDelete(cookie,cook);
				}								
			}

			if(cookies.preserve_request.keyExists("url")){
				url.append(cookies.preserve_request.url);
				rc.Append(cookies.preserve_request.url);
				var deleteCookies = flattenDataStructureForCookies(data=cookies.preserve_request.url, prefix="preserve_request.url", ignore=[]);							
				for(var cook in deleteCookies){
					header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";
					structDelete(cookie,cook);
				}				
			}			
		}


		if(cookies.keyExists("preserve_response")){			
			form.append(cookies.preserve_response);
			rc.append(cookies.preserve_response);
			var deleteCookies = flattenDataStructureForCookies(data=cookies.preserve_response, prefix="preserve_response", ignore=[]);			
			for(var cook in deleteCookies){
				// structDelete(cookie,cook);
				header name="Set-Cookie" value="#ucase(cook)#=; path=/; Max-Age=0; Expires=Thu, 01-Jan-1970 00:00:00 GMT";
				structDelete(cookie,cook);
			}
		}

		if(rc.keyExists("submit_overload")){
			if(!isJson(rc.submit_overload)){
				throw("The data in a form submit_overload must be json");
			}
			var json = deserializeJson(form.submit_overload);
			for(var key in json){
				form[key] = json[key];
				rc[key] = json[key];
			}
		}		

		form.append(recurseConvertStructArrayToArrays(duplicate(form)));
		rc.append(recurseConvertStructArrayToArrays(duplicate(rc)));

		//Append anything in the client scope to the RC scope as this is also to be used for controller arguments		
		for(key in client){
			if(!rc.keyExists(key)){
				if(!isNull(client[key])){
					rc[key] = client[key];					
				}
			}
		}		
		
		request._zero.zeroClient = new zeroClient();
		if(url.keyExists("clearClient")){
			// writeDump(request._zero.zeroClient.getValues());
			request._zero.zeroClient.getValues().clear();
			request._zero.zeroClient.persist();
			// abort;
		}

		var clientValues = duplicate(request._zero.zeroClient.getValues());
		for(var key in clientValues){
			if(!rc.keyExists(key)){
				if(!isNull(clientValues[key])){
					rc[key] = clientValues[key];					
				}
			}
		}				

		if(rc.keyExists("form_state")){			
			if(rc.keyExists("current_step")){
				request._zero.zeroFormState = new zeroFormState(steps:rc.form_state, currentStep:rc.current_step, clientStorage:request._zero.zeroClient.getValues());				
			} else {
				request._zero.zeroFormState = new zeroFormState(steps:rc.form_state, clientStorage:request._zero.zeroClient.getValues());				
			}
		}

		if(request._zero.keyExists("zeroFormState") and cgi.request_method == "GET"){
			var formData = request._zero.zeroFormState.getFormData();			
			for(var key in formData){
				rc[key] = formData[key];
				form[key] = formData[key];					
			}
		}

		if(rc.keyExists("delete_key")){
			if(!isArray(rc.delete_key)){
				rc.delete_key = [rc.delete_key];
			}

			for(var key in rc.delete_key){
				structDelete(form, key);
				structDelete(rc, key);
				structDelete(client, key);
			}
			// writeDump(rc);
			// abort;
		}

		// rc.append(client);

		//Setup an alias for redirect
		if(rc.keyExists("goto_before")){
			rc.redirect = rc.goto_before;
		}

		// if(cgi.request_method contains "GET"){
		// 	writeDump(cookie);
		// 	writeDump(form);
		// 	writeDump(rc);
		// 	abort;
			
		// }
		// 
		

		if(rc.keyExists("redirect")){

			if(request._zero.keyExists("zeroFormState")){				
				if(CGI.request_method contains "POST"){					
					request._zero.zeroFormState.setFormData(form);
					
					if(rc.keyExists("start_over")){
						request._zero.zeroFormState.start();
					} else if(rc.keyExists("first_step")){
							request._zero.zeroFormState.first();
					} else if(rc.keyExists("move_forward")){
						request._zero.zeroFormState.moveForward();
					} else if(rc.keyExists("move_backward")){								
						request._zero.zeroFormState.moveBackward();								
					} else if(rc.keyExists("current_step")){
						request._zero.zeroFormState.completeStep(rc.current_step)
					} else {
						request._zero.zeroFormState.start();
					}

					if(rc.keyExists("form_state_clear_form")){								
						request._zero.zeroFormState.clearFormData();
					}
				}										
			}

			if(rc.keyExists("anchor")){
				rc.redirect = rc.redirect & "##" & rc.anchor;
			}

			if(rc.keyExists("preserve_key")){
				if(!isArray(rc.preserve_key)){
					rc.preserve_key = [rc.preserve_key];
				}
				for(var value in rc.preserve_key){
					cookie["preserve_#value#"] = rc[value];
				}
			}

			if(rc.keyExists("preserve_form")){												
				var formKeys = flattenDataStructureForCookies(data=form, prefix="preserve_form", ignore="delete_key,preserve_redirect,redirect,preserve_map,preserve_response,preserve_form,goto_before,goto,submit_overload");
				cookie.append(formKeys);	

			}

			doTrace(rc, "RC before() redirect");
			doTrace(FORM, "FORM before() redirect");
			doTrace(cookie, "COOKIE before() redirect");
			writeLog(file="zero_trace", text="do before() redirect");
			request._zero.zeroClient.persist();				
			location url="#rc.redirect#" addtoken="false" statuscode="303";				
		}

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

	 /**
	 * Breaks a camelCased string into separate words
	 * 8-mar-2010 added option to capitalize parsed words Brian Meloche brianmeloche@gmail.com
	 *
	 * @param str      String to use (Required)
	 * @param capitalize      Boolean to return capitalized words (Optional)
	 * @return Returns a string
	 * @author Richard (brianmeloche@gmail.comacdhirr@trilobiet.nl)
	 * @version 0, March 8, 2010
	 */
	function camelToUnderscore(str) {
	    var rtnStr=lcase(reReplace(arguments.str,"([A-Z])([a-z])","_\1\2","ALL"));
	    if (arrayLen(arguments) GT 1 AND arguments[2] EQ true) {
	        rtnStr=reReplace(arguments.str,"([a-z])([A-Z])","\1_\2","ALL");
	        rtnStr=uCase(left(rtnStr,1)) & right(rtnStr,len(rtnStr)-1);
	    }
		return trim(rtnStr);
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

	function recurseFindArguments(context, args, errors={}){

		var out = {};

		cfmltypes = [
			"any",
			"array",
			"binary",
			"boolean",
			"component",
			"date",
			"guid",
			"numeric",
			"query",
			"string",
			"struct",
			"uuid",
			"variableName",
			"void",						
		];


		var isArrayType = function(string type){
			return right(type, 2) == "[]";
		}

		var getArrayType = function(string type){
			return left(type, len(type) - 2);
		}

		var addError = function(name, value){
			
			if(variables.zero.throwOnFirstArgumentError){
				writeDump("Zero encountered an error in trying to popluate the values");
				writeDump(arguments);
				writeDump(callStackGet());
				abort;				
			} else {
				errors.insert(arguments.name, arguments.value);
			}

		}

		// writeDump(args);
		// writeDump(context);
		outerArguments: for(var arg in args){
			// writeDump(arg);
			//Guard statement if the argument is required
			if(arg.keyExists("required") and arg.required){
				if(!context.keyExists(arg.name)){
					addError(arg.name, {message:"The argument #arg.name# was required but was not passed in", original_value:nullValue()});
					continue;
				}
			}

			if(isArrayType(arg.type)){

				if(context.keyExists(arg.name)){
					if(!isArray(context[arg.name])){					
						addError(arg.name, {message:"The argument #arg.name# was not valid, it must be an array of #getArrayType(arg.type)#", original_value:context[arg.name]});
					} else {

						var arrayOut = [];
						var type = getArrayType(arg.type);
						for(var item in context[arg.name]){

							if(cfmlTypes.findNoCase(type)){

								if(!isValid(type, item)){
									addError(arg.name, {message:"One of the values in the #arg.name# array was not of the correct type #type#", original_value:item});
									continue outerArguments;
								} else {
									arrayOut.append(item);															
								}

							} else {
								
								var newContext = {"#arg.name#":item};
								var newArgs = [{
									type:type,
									required:true,
									name:arg.name,
								}];
								arrayOut.append(recurseFindArguments(context=newContext, args=newArgs, errors=errors));							
							}
						}

						out.insert(arg.name, arrayOut);

					}					
				}

			} else {
				if(context.keyExists(arg.name)){
					if(cfmlTypes.findNoCase(arg.type)){

						if(!isValid(arg.type, context[arg.name])){
							addError(arg.name, {message:"The argument #arg.name# was not valid, it must be a #arg.type#", original_value:context[arg.name]});
						} else {						
							out.insert(arg.name, context[arg.name], false)						
						}
					} else {					

						var filePaths = [
							{
								file:expandPath("/#variables.zero.argumentModelValueObjectPath#/#arg.type#.cfc"),
								com:"#variables.zero.argumentModelValueObjectPath#.#arg.type#"
							},
							{
								file:expandPath("/validations/#arg.type#.cfc"),
								com:"validations.#arg.type#"
							},
							
						];					

						var componentPath = nullValue();
						for(var path in filePaths){
							if(fileExists(path.file)){	
								componentPath = path.com;
								break;
							}
						}

						if(isNull(componentPath)){
							throw("Could not load the type #arg.type#, it could not be found");
						} else {
							// writeDump(componentPath);
							// abort;
							var meta = getComponentMetaData(componentPath);
							var cfc = createObject(componentPath);

							try {
								var initMeta = getMetaDataFunctionArguments(cfc,"init");													
							} catch(any e){
								throw("The object #arg.type# did not have a default init constructor. This is necessary to populate from the request");
							}

							if(isInstanceOf(cfc,"valueObject")){

								if(arrayLen(initMeta) > 1){
									throw("Error when trying to populate #meta.name# A component of type valueObject can only have one argument");
								}

								try {
									out.insert(arg.name, cfc.init(context[arg.name]));								
								}catch(any e){
									addError(arg.name, {message:e.message, original_value:context[arg.name]});
								}
								// writeDump(cfc);							
								// writeDump(context[arg.name]);
							} else {

								if(isSimpleValue(context[arg.name])){

									try {
										var temp = cfc.init(context[arg.name]);								
										out.insert(arg.name, cfc);															
									} catch(any e){
										addError(arg.name, {message:e.message, original_value:context[arg.name]});
									}
								} else {

									if(isStruct(context[arg.name])){

										if(arrayLen(initMeta) == 1){
											try {
												var temp = cfc.init(context[arg.name]);								
												out.insert(arg.name, cfc);															
											} catch(any e){
												addError(arg.name, {message:e.message, original_value:context[arg.name]});
											}

										} else {
											var argCollection = recurseFindArguments(context[arg.name], initMeta, errors);

											// writeDump(context[arg.name]);
											// writeDump(argCollection);
											try {
												var temp = cfc.init(argumentCollection=argCollection);								
												out.insert(arg.name, cfc);															
											} catch(any e){
												addError(arg.name, {message:e.message, original_value:context[arg.name]});
											}																		
										}

									} else if(isArray(context[arg.name])) {
										
										if(arrayLen(initMeta) == 1){

											if(isArrayType(initMeta[1].type)){

												//- 9/27/2016 Not fully implemented, need to think about this further

												out.insert(arg.name, recurseFindArguments(context={"#arg.name#":context[arg.name]}, args=initMeta, errors=errors));

												// var arrayOut = [];
												
												// for(var item in context[arg.name]){

												// 	var newArgs = [{
												// 		type:getArrayType(initMeta[1].type),
												// 		required:true,
												// 		name:arg.name,
												// 	}];
												// 	var newContext = {"#arg.name#":item};
												// 	arrayOut.append(recurseFindArguments(context=newContext, args=newArgs, errors=errors));
												// }

												// out.insert(arg.name, arrayOut);

											} else {
												try {
													var temp = cfc.init(context[arg.name]);								
													out.insert(arg.name, cfc);															
												} catch(any e){
													addError(arg.name, {message:e.message, original_value:context[arg.name]});
												}
											}
										}										
									}
																	
								}

							}
						}
						
					}
				} 
			}

			
		}	

		return out;
	}

	function getArgumentsToPass(cfc, method){
    	var args = getMetaDataFunctionArguments(cfc, method);	    	
		argsToPass = {};

		request.context.headers = request._fw1.headers;

		/*
		Zero will allow controller arguments to be snake_case or camelCase. If Zero encounters
		a snake_case argument, it will convert it to camelCase also assuming that both arguments
		are intended to be the same value, but snake_case is used for API and HTML presentation. We
		achieve this by simply copying the values from the snake_case to a camelCase version
		 */			
		for(var key in request.context){
			var keyNoUnderscore = replaceNoCase(key,"_","","all");
			if(!request.context.keyExists(keyNoUnderscore)){
				request.context[keyNoUnderscore] = request.context[key];
			}
		}

		request._zero.argumentErrors = {};
		argsToPass = recurseFindArguments(context=request.context, args=args, errors=request._zero.argumentErrors);
		// for(var arg in args){
		// 	writeLog(file="zero_trace", text="Check arg: #arg.name#");
		// 	if(structKeyExists(request.context,arg.name)){

		// 		cfmltypes = [
		// 			"any",
		// 			"array",
		// 			"binary",
		// 			"boolean",
		// 			"component",
		// 			"date",
		// 			"guid",
		// 			"numeric",
		// 			"query",
		// 			"string",
		// 			"struct",
		// 			"uuid",
		// 			"variableName",
		// 			"void",						
		// 		];

		// 		if(cfmltypes.findNoCase(arg.type)){

		// 			if(!isValid(arg.type, request.context[arg.name])){
		// 				request._zero.argumentErrors.insert(arg.name, {message:"The argument #arg.name# was not valid, it must be a #arg.type#", original_value:request.context[arg.name]});
		// 			} else {
		// 				argsToPass[arg.name] = request.context[arg.name];													
		// 			}

		// 		} else {
		// 			try {
		// 				getComponentMetaData("#variables.zero.argumentModelValueObjectPath#.#arg.type#");
		// 				try {
		// 					argsToPass[arg.name] = createObject("#variables.zero.argumentModelValueObjectPath#.#arg.type#").init(value=request.context[arg.name]);
		// 				} catch(any e){								
		// 					// writeDump("#variables.zero.argumentModelValueObjectPath#.#arg.type#");
		// 					// writeDump(e);
		// 					// abort;
		// 					request._zero.argumentErrors.insert(arg.name, {message:e.message, original_value:request.context[arg.name]})								
		// 				}							
		// 			} catch(any e){
		// 				try {
		// 					//Try to get one of the value objects shipped with Zero
		// 					// getComponentMetaData("#variables.zero.argumentValidationsValueObjectPath#.#arg.type#");							
		// 					// argsToPass[arg.name] = createObject("#variables.zero.argumentValidationsValueObjectPath#.#arg.type#").init(request.context[arg.name], args.name).toString();
							

		// 					getComponentMetaData("validations.#arg.type#");				
		// 					try {
		// 						argsToPass[arg.name] = createObject("validations.#arg.type#").init(name=arg.name, value=request.context[arg.name]);									
		// 					}catch(any e){
		// 						request._zero.argumentErrors.insert(arg.name, {message:e.message, original_value:request.context[arg.name]})
		// 					}
							
		// 				} catch(any e){															
		// 					throw("Could not process #arg.type# because it does not exist", 500);
		// 				}
		// 			}
		// 		}
		// 	} 
		// }
		return argsToPass;
    }

	private void function doController( struct tuple, string method, string lifecycle ) {
        var cfc = tuple.controller;
        writeLog(file="zero_trace", text="start doController for cfc:#getMetaData(cfc).name#, method:#method#, lifecycle:#lifecycle#");

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

                		var argsToPass = getArgumentsToPass(cfc, method);                		
                		if(!request._zero.argumentErrors.isEmpty()){
                			request._zero.controllerResult = {
                				"success":false,
                				"errors":request._zero.argumentErrors
                			}                			
            			} else {
	                		request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = argsToPass)' );
            			}

                	} else {
                		request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );	
                	}

                	if(controllerHasFunction(cfc, "result")){
                		if(isNull(request._zero.controllerResult)){
							if(variables.zero.throwOnNullControllerResult){								
								throw("The controller #request.action# #request.item# did not have a return value but it expected one for a json request")
							}
						} else {            				
                			request._zero.controllerResult = evaluate( 'cfc.result( request._zero.controllerResult )' );
						}
                	}
	                
            	} else {

            		/* Zero overrides what happens with after methods to pass in the result of the controller call as
            		an additional parameter
            		*/
            		if(method == "after"){

            			if(isNull(request._zero.controllerResult)){
            				if(variables.zero.throwOnNullControllerResult){								
								throw("The controller #request.action# #request.item# did not have a return value but it expected one for a json request")
							}
            			} else {
            				request._zero.controllerLifecycleResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers, controllerResult = 	request._zero.controllerResult)' );
            			}

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

    public function encodeResultFor(type="HTML", required any str){

    	if(!isNull(str)){
	    	if(isArray(str)){
	    		loop array=str index="i" item="value" {

	    			if(!isNull(value)){
		    			if(isArray(value) or isStruct(value)){
		    				encodeResultFor(type, value);    				
		    			} else {
		    				str[i] = esapiEncode(type, value);   				    							
		    			}	    				
	    			}
	    		}
	    	} else if(isStruct(str)){
	    		for(var key in str){
	    			if(!isNull(str[key])){
		    			if(isArray(str[key]) or isStruct(str[key])){
		    				encodeResultFor(type, str[key]);    				
		    			} else {
		    				str[key] = esapiEncode(type, str[key]);    								    				
		    			}    				    				
	    			}
	    		}
	    	}    		
    	}
    	return str;
    }

    public function entityToJson(required any arrayOrComponent, nest={}){ 	
    	if(isArray(arrayOrComponent)){
    		var entityName = request.section;   		    		
    	} else {
    		//Try to get the name from the actual entity because we assume that it is singular
	    	try {
	    		var entityName = getEntityName(arrayOrComponent);    		
	    	} catch("zeroCantInferEntityName"){
	    		var entityName = request.section;
	    	}    		
    	}
    	var out = {
    		"#entityName#":new serializer().serializeEntity(arrayOrComponent, nest)    	
    	}
    	return out;
    }

    public function flattenDataStructureForCookies(required any data, prefix="", ignore=[]){
    	var prefix = arguments.prefix;
		var pile = {};
    	var recurseData = function(data, currentPath="", pile){
    		if(isArray(data)){

    			var index = 0;
    			for(var item in data){
    				index++;
					if(currentPath == ""){
						var path = currentPath & "#index#";						
					} else {
						var path = currentPath & "." & "#index#";						
					}

    				if(isStruct(item) or isArray(item)){
    					recurseData(data=item, currentPath=path, pile=pile);
    				} else {
    					pile.insert(path, item);
    				}
    			}

			} else if(isStruct(data)) {
				loopStruct: for(var key in data){

					for(var ignoreItem in ignore){
						if(lcase(key) == lcase(ignoreItem)){
							continue loopStruct;
						}
					}

					if(currentPath == ""){
						var path = currentPath & key;						
					} else {
						var path = currentPath & "." & key;						
					}

					if(isStruct(data[key]) or isArray(data[key])){
						recurseData(data = data[key], currentPath=path, pile=pile)
					} else {
						pile.insert(path, data[key], true);
					}
				}

			} else {
				throw("json data was not an array or struct, cannot convert");
			}

    		return pile; 	
    	}
    	recurseData(data=arguments.data, pile=pile);

    	if(prefix != ""){
    		for(var key in pile){
    			pile["#prefix#.#key#"] = pile[key];
    			pile.delete(key);
    		}
    	}

    	return pile;
    }

    public function expandFlattenedData(data){
    	var out = duplicate(data);
    	structKeyTranslate(out, true);    	
    	var recurseStructs = function(str){
    		// writeDump(str);
    		if(isArray(str)){
    			for(var item in str){
    				recurseStructs(item);    				
    			}
			} else if(isStruct(str)){

				for(var key in str){					
					if(isStruct(str[key])){
						if(structIsReallyArray(str[key])){
							str[key] = convertStructArrayToArray(str[key]);					
						}					
						recurseStructs(str[key]);
					}
				}

	    	} else {
				//Do nothing, it is a simple value
			}
    	}
    	recurseStructs(out);
    	return out;
    }

    public function getCSRFToken(){
    	if(!request.keyExists("CSRF_TOKEN")){
    		request.CSRF_TOKEN = createUUID();
    		cookie.CSRF_TOKEN = request.CSRF_TOKEN;    		
    	}
    	return cookie.CSRF_TOKEN;
    }

    public boolean function hasEntityLoader(entityName){
    	if(structKeyExists(this, "get#entityName#byId") or structKeyExists(variables, "get#entityName#byId")){
    		return true;
    	} else {
    		return false;
    	}
    }

    public function recurseConvertStructArrayToArrays(data){
    	out = data
    	var recurseStructs = function(str){
    		// writeDump(str);
    		if(isArray(str)){
    			for(var item in str){
    				recurseStructs(item);    				
    			}
			} else if(isStruct(str)){

				for(var key in str){					
					if(isStruct(str[key])){
						if(structIsReallyArray(str[key])){
							str[key] = convertStructArrayToArray(str[key]);					
						}					
						recurseStructs(str[key]);
					}
				}

	    	} else {
				//Do nothing, it is a simple value
			}
    	}
    	recurseStructs(out);
    	return out;
    }

    public boolean function structIsReallyArray(required struct str){
    	var success = true;
    	for(var key in str){
    		if(!isNumeric(key)){
    			success = false;
    		}
    	}
    	return success;
    }

    public function convertStructArrayToArray(required struct str){
    	var out = [];
    	var keys = str.keyArray().sort("numeric");    	

    	for(var key in keys){
    		out.append(str[key]);
    	}
    	return out;
    }

    private string function getEntityName(arrayOrComponent){
		if(isArray(arrayOrComponent)){
			if(arrayLen(arrayOrComponent) == 0){
				throw("Could not infer the entity name from an empty array. use the entityToJson() method manually", "zeroCantInferEntityName");
			} else {
				var entity = arrayOrComponent[1];								
			}
		} else {
			var entity = arrayOrComponent;
		}	

		var meta = getMetaData(entity);
		var name = meta.name;
		return listLast(name,".");
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

    public boolean function isComponentOrArrayOfComponents(required arrayOrComponent){
    	if(isStruct(arrayOrComponent) and !isObject(arrayOrComponent)){
    		return false;
    	}

    	if(isArray(arrayOrComponent)){    	
    		if(arrayLen(arrayOrComponent) > 0){

    			if(isNull(arrayOrComponent[1])){
    				/*
    				Handles the case where Lucee generates an ordered
    				array for arguments that has null values. They still 
    				evaluate to an object for some reason
    				 */
    				return false;
    			} else {
	    			if(isObject(arrayOrComponent[1])){
	    				return true;
	    			} else {
	    				return false;
	    			}    				
    			}
    		} else {    			
    			return false;
    		}
    	} else if(isObject(arrayOrComponent)){
    		return true;
    	} else {
    		return false;
    	}
    }

    public function injectCSRFIntoForms(string output){

    	var pos = 0;
    	var len = 0;
    	do {
    		var result =  reFindNoCase("<form\b[^>]*>", output, pos + len + 1, true);
    		// writeDump(result);
    		pos = result.pos[1];
    		len = result.len[1];

    		if(pos > 0){
    			var csrf = '<input type="hidden" name="csrf_token" value="#getCSRFToken()#" />';
    			var output = insert(csrf, output, pos + len - 1);    			
    		}
    		
    	} while(pos);

    	return output;
    }

	/**
	 * Createa a default RESTful route for each controller present. loadAvailableControllers() must be called within onRequestStart() because
	 * it depends on the setting usingSubsystems which can be set by the inheriting Application.cfc
	 * in the controllers folder 
	 * @return {array} The routes created by this function
	 */
	private array function loadAvailableControllers(){
		writeLog(file="zero_trace", text="Load controllers");
		if(!isNull(request.alreadyLoadedControllers)){
			return [];
		}

		if(isNull(variables.framework.routes)){
			variables.framework.routes = [];
		}

		if(variables.framework.usingSubsystems){
			loadSubsystemControllers();
		} else {						
			loadControllers(expandPath("controllers"));
		}

		if(!isNull(this.setupRoutes)){
			this.setupRoutes(variables.framework.routes);
		}		
		request.alreadyLoadedControllers = true;

		//Add as the last item a universal route for the default subsystem to route anything
		//to it back to the subsystem		
		return variables.framework.routes;
	}

	private array function loadControllers(required path){
		var controllers = directoryList(path=arguments.path, filter="*.cfc");		
		for(var controller in controllers){
			file = getFileFromPath(controller);
			name = listFirst(file, ".");
			
			var meta = getComponentMetaData("controllers.#name#");
			var nested = listToArray(meta.nested?:"");
			for(var nest in nested){
				//Add nesting
				variables.framework.routes.prepend({ "$RESOURCES" = { resources = "#name#", nested="#nest#"} });
				
				//Add route for linking resource					
				variables.framework.routes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/link*' = '/#nest#/link/#name#_id/:#nest#_id/id/:id' });

				//Add route for unlinking resource					
				variables.framework.routes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/unlink*' = '/#nest#/unlink/#name#_id/:#nest#_id/id/:id' });					
			}				
			
			variables.framework.routes.prepend({ "$RESOURCES" = { resources = name} })
		}
		return variables.framework.routes;
	}

	private array function loadSubsystemControllers(){
		// variables.framework.routes = [];
		var subsystems = directoryList(path=expandPath(variables.framework.base));
		for(var subsystem in subsystems){
			subsystemName = listLast(subsystem, "/");
			var controllers = directoryList(path="#subsystem#/controllers", filter="*.cfc");

			for(var controller in controllers){
				file = getFileFromPath(controller);
				name = listFirst(file, ".");
				variables.framework.routes.prepend({ "$RESOURCES" = { resources = name, subsystem = subsystemName } })				

				var meta = getComponentMetaData("#variables.framework.base#.#subsystemName#.controllers.#name#");
				var nested = listToArray(meta.nested?:"");
				for(var nest in nested){
					//Add nesting
					variables.framework.routes.prepend({ "$RESOURCES" = { resources = "#name#", nested="#nest#", subsystem = subsystemName} });
					
					//Add route for linking resource					
					variables.framework.routes.prepend({'$POST/#subsystemName#/#name#/:#name#_id/#nest#/:id/link*' = '/#subsystemName#:#nest#/link/#name#_id/:#name#_id/id/:id' });

					//Add route for unlinking resource					
					variables.framework.routes.prepend({'$POST/#subsystemName#/#name#/:#name#_id/#nest#/:id/unlink*' = '/#subsystemName#:#nest#/unlink/#name#_id/:#name#_id/id/:id' });					
				}
			}
		}
		return variables.framework.routes;
	}

	public function onError(error, event){
		
		switch(request._zero.contentType){
			case "json":				
				if(!error.errorCode == "0"){
					var errorcode = error.errorCode
				} else {
					var errorcode = "500";
				}

				if(errorCode ==""){
					errorCode = "500";					
				}

				if(error.type contains "zeroController"){
					var out = {
						"success":false,
						"message":error.message,
						"status_code":errorCode,							
					}		
				} else {					
					if(variables.zero.outputNonControllerErrors){					
						var out = {
							"success":false,
							"message":error.message,
							"status_code":errorCode,
							"details":error
						}		
					} else {
						var out = {
							"success":false,
							"message":"There was an error processing your request. Please try again.",							
						}
					}
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

	public function doTrace(required data, label=""){
		if(variables.zero.traceRequests){		
			var out = "";
			// writeDump(label);
			savecontent variable="out"{
				writeDump(var=data, label=label);
			}
			request.zeroTrace = request.zeroTrace & out;
		}			
	}

	function onRequest(){		
		writeLog(file="zero_trace", text="start onRequest()");		

		if(!request.keyexists("zeroTrace")){
			request.zeroTrace = "";				
		}

		if(variables.zero.traceRequests){

			if(url.keyExists("clearTrace")){
				if(directoryExists("./trace")){
					directoryDelete("./trace", true);					
				}
			}


			if(!directoryExists("./trace")){
				directoryCreate("./trace");
			}
		}

		doTrace(form,"FORM in onRequest()");
		var finalOutput = "";
		savecontent variable="finalOutput" {
			super.onRequest();			
		}				

		if(cookie.keyExists('zeropreload')){
			if(application.preloadCache.keyExists(cookie.zeropreload)){					
				application.preloadCache[cookie.zeropreload].complete = true;
				application.preloadCache[cookie.zeropreload].output = finalOutput;
				writeLog(file="zero", text="saved output to cache and aborted #cookie.zeropreload#");
				structDelete(cookie,"zeropreload");
				client = {};
				structClear(client);
				abort;
			}
		}

		finalOutput = response(finalOutput);
		finalOutput = injectCSRFIntoForms(finalOutput);
		writeOutput(finalOutput);		

		if(variables.zero.traceRequests){

			var traces = directoryList(path="./trace", listInfo="name");
			var ids = [];
			for(var traceid in traces){
				ids.append(listFirst(traceid,"."));
			}

			if(arrayLen(ids) == 0){
				nextId = 1;
			} else {
				nextId = arrayLen(ids) + 1				
			}			

			fileWrite("./trace/#nextId#.html", request.zeroTrace);
		}

		writeLog(file="zero_trace", text="end zero.onRequest()");

		//Clear out the client at the end of the request
		// client = {};
		// structClear(client);		
	}

	/**
	* We have to define our own onSessionStart because fw/1 builds resources rotes before initializing the session. This causes
	* views to be lost for some reason (an issue internal to FW/1). By defining our own onSessionStart and calling
	* buildResourceRoutes() when a new session is created, the routes are generated properly
	*	
	*/
	public void function onSessionStart(rc) {
		writeLog(file="zero_trace", text="start onSessionStart()");
		loadAvailableControllers();		
		super.onSessionStart();
	}	

	function onRequestStart(){
		writeLog(file="zero_trace", text="start onRequestStart()");
		variables.zero.throwOnNullControllerResult = variables.zero.throwOnNullControllerResult?: true;
		variables.zero.argumentCheckedControllers = variables.zero.argumentCheckedControllers?: true;
		variables.zero.equalizeSnakeAndCamelCase = variables.zero.equalizeSnakeAndCamelCase?: true;
		variables.zero.outputNonControllerErrors = variables.zero.outputNonControllerErrors?: false;
		variables.zero.argumentModelValueObjectPath = variables.zero.argumentModelValueObjectPath?: "model";
		variables.zero.argumentValidationsValueObjectPath = variables.zero.argumentValidationsValueObjectPath?: "validations";
		variables.zero.csrfProtect = variables.zero.csrfProtect?: true;
		variables.zero.encodeResultForHTML = variables.zero.encodeResultForHTML ?: true;
		variables.zero.traceRequests = variables.zero.traceRequests ?: false;
		variables.zero.cacheControllers = variables.zero.cacheControllers ?: false;	
		variables.zero.throwOnFirstArgumentError = variables.zero.throwOnFirstArgumentError ?: false;
		
		if(isNull(application.zero)){application.zero = {}};
		
		if(application.zero.keyExists("routes")){
			variables.framework.routes = application.zero.routes;
		} else {
			loadAvailableControllers();
			application.zero.routes = variables.framework.routes;			
		}
		

		
		if(!application.keyExists('preloadCache')){
			application.preloadCache = {};
		}
		
		if(cookie.keyExists('zeropreload')){
			if(application.preloadCache.keyExists(cookie.zeropreload)){

				while(!application.preloadCache[cookie.zeropreload].complete){
					sleep(10);
				}
				// sleep(500);
				writeLog(file="zero", text="output from cache and aborted #cookie.zeropreload#");
				writeOutput(application.preloadCache[cookie.zeropreload].output);
				structDelete(application.preloadCache,cookie.zeropreload);
				structDelete(cookie,"zeropreload");
				structDelete(client,"zeropreload");
				abort;

			} else {
				application.preloadCache[cookie.zeropreload] = {
					complete:false,
					output:""
				}
			}
		}

		super.onRequestStart(argumentCollection=arguments);			

	}

	public function serialize(required any value, struct nest={}){
		return new serializer().serializeEntity(value, nest);
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

    public function unescapeHTML(required string){
    	//Lucee does not have a function to unescape HTML characters, but we can use the built in 
    	//Apache commons library
    	//http://stackoverflow.com/questions/1646839/decode-numeric-html-entities-in-coldfusion
    	var StrEscUtils = createObject("java", "org.apache.commons.lang.StringEscapeUtils");
		var Character = StrEscUtils.unescapeHTML(arguments.string);
		return Character;
    }

}