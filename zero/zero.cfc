import serializer;
component extends="one" {

	this.customTagPaths = ["./vendor/handlebars.lucee"];

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
	  { method = 'update', httpMethods = [ '$PUT','$POST' ], includeId = true, routeSuffix = '/update' },

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

		/*
		Transfers data from a view to another view. In the default use, this bypasses
		having to send data through a controller. The controller can also return a view_state
		variable which takes precedence over the view_state passed from a view
		 */
		if(form.keyExists("view_state")){
			if(request._zero.controllerResult.keyExists("view_state")){
				var newStruct = duplicate(form.view_state);
				structAppend(newStruct, request._zero.controllerResult.view_state, true);
				request._zero.controllerResult.view_state = newStruct;
			} else {
				request._zero.controllerResult.view_state = form.view_state;
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
					renderData("json", {} );
				} else {
					renderData("json", request._zero.controllerResult, request._zero.controllerResult.status_code?:"200");
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
								if(rc.keyExists("clear_step_data")){
									request._zero.zeroFormState.moveBackward(clearStepData=true);
								} else {
									request._zero.zeroFormState.moveBackward();
								}
							} else if(rc.keyExists("clear_step_data")){
								request._zero.zeroFormState.clearStepData();
							} else if(rc.keyExists("start")){
								request._zero.zeroFormState.start();
							} else if(rc.keyExists("resume")){
								request._zero.zeroFormState.resume();
							}

							if(rc.keyExists("form_state_clear_form")){
								request._zero.zeroFormState.clearFormData();
							}
						} else {

							if(rc.keyExists("on_failure")){
								if(rc.on_failure contains "clear_step_data"){
									request._zero.zeroFormState.clearStepData();
									// writeDump(request._zero.zeroFormState);
									// abort;
								}
							}
						}
					}
				}

				if(rc.keyExists("goto_fail")){
					if(request._zero.controllerResult.keyExists("success") and request._zero.controllerResult.success == false){
						rc.goto = rc.goto_fail;
						if(!form.keyExists("preserve_response")){
							form.preserve_response = true;
						}

						if(!request._zero.keyExists("zeroFormState")){
							form.preserve_request = true;
						}

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

					if(structKeyExists(form,"map_response")){
						var maps = deserializeJson(form.map_response);
						for(var map in maps){
							for(var key in map){
								var result = evaluate("request._zero.controllerResult.#key#");
								var value = map[key];
								request._zero.controllerResult[value] = result;
							}
						}
					}

					if(structKeyExists(form,"preserve_response")){
						if(isBoolean(form.preserve_response)){
							var prefix = "preserve_response";
						} else if(trim(form.preserve_response) == ""){
							var prefix = "preserve_response";
						} else if(isJson(form.preserve_response)){

							var actions = deserializeJson(form.preserve_response);
							for(var action in actions){
								if(action == "map"){
									var newResult = {}
									var maps = actions[action];
									for(var map in maps){
										for(var key in map){
											var result = evaluate("request._zero.controllerResult.#key#");
											var value = map[key];
											newResult[value] = result;
										}
									}
									request._zero.controllerResult = newResult;
									var prefix = "preserve_response";
								}
							}
						}
						else {
							var prefix = "preserve_response.#form.preserve_response#";
						}
						// writeDump(prefix);

						var formKeys = flattenDataStructureForCookies(data=request._zero.controllerResult, prefix=prefix, ignore="delete_key,goto,goto_fail,preserve_form,submit_overload,redirect,map,preserve_response");
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
							var formKeys = flattenDataStructureForCookies(data=form, prefix="preserve_form", ignore="delete_key,goto,goto_fail,preserve_form,submit_overload,redirect,map,preserve_response");
							cookie.append(formKeys);
						}
					}


					if(form.keyExists("preserve_request")){
						var formKeys = flattenDataStructureForCookies(data=form, prefix="preserve_request.form", ignore="delete_key,goto,goto_fail,preserve_form,submit_overload,redirect,map,preserve_response,preserve_request");
						cookie.append(formKeys);

						var formKeys = flattenDataStructureForCookies(data=url, prefix="preserve_request.url", ignore="delete_key,goto,goto_fail,preserve_form,submit_overload,redirect,map,preserve_response,preserve_request");
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

				rc = recurseAndLowerCaseTheKeys(rc);

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

		request._zero.argumentErrors = {};

		if(url.keyExists("clearClient")){
			structClear(client);
			client = {};
		}

		if(rc.keyExists("form_state") and rc.keyExists("preserve_form")){
			throw("Do not use form_state and preserve_form together. Preserve form is for simple single step forms. Form state is for complex multi step forms.")
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

			//Loop through each key in the preserve response and add it
			//to the form
			for(var key in cookies.preserve_response){

				if(isStruct(cookies.preserve_response[key])){
					if(!form.keyExists(key)){
						form[key] = {}
					}
					form[key].append(cookies.preserve_response[key]);

					if(!rc.keyExists(key)){
						rc[key] = {}
					}
					rc[key].append(cookies.preserve_response[key]);
				} else {
					form[key] = cookies.preserve_response[key];
					rc[key] =  cookies.preserve_response[key];
				}
			}

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

		if(form.keyExists("delete_empty_fields")){
			var fields = listToArray(form.delete_empty_fields);
			for(var field in fields){
				if(isDefined("form.#field#") and getVariable("form.#field#") == ""){
					form.delete(listFirst(field,"."));
					rc.delete(listFirst(field,"."));
				}
			}
		}

		// structKeyTranslate(form, true);
		form.append(new zeroStructure(form).getValues());
		// form.append(recurseConvertStructArrayToArrays(duplicate(form)));
		form.append(new zeroStructure(rc).getValues());
		// rc.append(recurseConvertStructArrayToArrays(duplicate(rc)));
		// rc.append(recurseConvertStructArrayToArrays(duplicate(rc)));

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
			request._zero.zeroClient.clear();
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

		if(cgi.request_method == "GET"){

			if(rc.keyExists("form_state")){
				var args = {
					steps:rc.form_state,
					clientStorage:request._zero.zeroClient.getValues(),
				}

				if(rc.keyExists("form_state_name")){
					args.name = rc.form_state_name;
				}
				request._zero.zeroFormState = new zeroFormState(argumentCollection=args);
			}
		}

		if(cgi.request_method == "POST"){
			if(form.keyExists("form_state")){
				var args = {
					steps:form.form_state,
					clientStorage:request._zero.zeroClient.getValues(),
				}

				if(form.keyExists("form_state_name")){
					args.name = form.form_state_name;
				}

				request._zero.zeroFormState = new zeroFormState(argumentCollection=args);
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
						if(rc.keyExists("clear_step_data")){
							request._zero.zeroFormState.moveBackward(clearStepData=true);
						} else {
							request._zero.zeroFormState.moveBackward();
						}
					} else if(rc.keyExists("clear_step_data")){
						request._zero.zeroFormState.clearStepData();
					} else if(rc.keyExists("start")){
						request._zero.zeroFormState.start();
					} else if(rc.keyExists("resume")){
						request._zero.zeroFormState.resume();
						// abort;
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

	public function appendRoute(required struct route){
		variables.framework.routes.append(arguments.route);
	}

	public function createFormState(required string steps, name, clientStorage={}){
		request._zero.zeroFormState = new zeroFormState(argumentCollection=arguments);
		return request._zero.zeroFormState;
	}

	public function deserializeObject(){

	}

	function recurseFindCFCArguments(any data, component cfc, method="init", errors={}, forceArgumentCollection=false, path={}){

		var out = {}
		var args = getMetaDataFunctionArguments(cfc, method);
		var cfcName = getMetaData(cfc).name.listLast(".");
		structInsert(arguments.path, cfcName, {});
		var data = data;

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

		var addError = function(name, value, subErrors){

			if(variables.zero.throwOnFirstArgumentError){
				// writeDump(arguments);
				// abort;
				writeDump("Zero encountered an error in trying to popluate the values");
				writeDump(arguments);
				writeDump(arguments.error);
				// writeDump(componentPath);
				writeDump(cfcName);
				writeDump(args);
				writeDump(data);
				writeDump(callStackGet());
				abort;
			} else {
				errors.insert(arguments.name, arguments.value);
				if(arguments.keyExists("subErrors")){
					arguments.value.sub_errors = arguments.subErrors;
					arguments.value.append(arguments.subErrors);
				}
			}

		}

		var isCFMLType = function(type){
			var find = cfmlTypes.findNoCase(type);
			if(find > 0){
				return true;
			} else {
				return false;
			}
		}

		var tryComplexObject = function(name, type, data){

			var filePaths = [
				{
					file:expandPath("/zero/validations/#arguments.type#.cfc"),
					com:"zero.validations.#arguments.type#"
				},
				{
					file:expandPath("/#variables.zero.argumentModelValueObjectPath#/#arguments.type#.cfc"),
					com:"#variables.zero.argumentModelValueObjectPath#.#arguments.type#"
				},
				{
					file:expandPath("/validations/#arguments.type#.cfc"),
					com:"validations.#arguments.type#"
				},
			];

			// writeDump(filePaths);
			if(variables.zero.keyExists("validationPaths")){
				for(var path in duplicate(variables.zero.validationPaths)){
					path.file = path.file.replaceNoCase("*", arguments.type);
					path.com = path.com.replaceNoCase("*", arguments.type);
					filePaths.append(path);
				}
			}

			var componentPath = nullValue();
			for(var path in filePaths){
				if(fileExists(path.file)){
					componentPath = path.com;
					break;
				}
			}

			if(isNull(componentPath)){
				addError(arguments.name, {message:"Could not load the type #arguments.type#, it could not be found", original_value:arguments.data});
				return;
			} else {

				try {
					var newCfc = createObject(componentPath);

					var subErrors = {};
					var newArgs = recurseFindCFCArguments(data=arguments.data, cfc=newCfc, errors=subErrors, path=path);

					if(!subErrors.isEmpty()){
						addError(arguments.name, {message:"Enountered errors while trying to populate #arguments.name#", original_value:arguments.data}, subErrors);
						return;
					}

					if(isNull(newArgs)){
						return;
					} else {
						var newCfc = newCfc.init(argumentCollection=newArgs);
						return newCfc;
					}

				} catch(any e){
					// writeDump(filePaths);
					// writeDump(variables.zero.validationPaths);
					// writeDump(e);
					// writeDump(newArgs);
					// writeDump(newCfc);
					// abort;
					addError(arguments.name, {message:e.message, original_value:arguments.data}, subErrors);

					return;
				}
			}

		}

		var getArgumentValues = function(name, type, isRequired, data){

			var name = arguments.name;
			var type = arguments.type;
			var isRequired = arguments.isRequired;
			var data = arguments.data;
			var out = {};
			if(isCFMLType(type)){
				if(!isValid(type, data)){
					addError(name, {message:"One of the values in the #name# array was not of the correct type #type#", original_value:data});
					return out;
				} else {
					out.insert(name, data);
					return out;
				}

			} else if(isArrayType(type)){
				// writeDump(local);abort;

				if(!isArray(data)){
					addError(name, {message:"The type was an arrayTyped of #type#, thus expected the data to be an array", original_value:data});
					return out;
				}

				var arrayType = getArrayType(type);

				if(isCFMLType(arrayType)){
					for(var item in data){
						if(!isValid(arrayType, item)){
							addError(name, {message:"One of the values in the array was not of the correct type #arrayType#", original_value:data});
							return out;
						}
					}
					out.insert(name, data);
					return out;

				} else {


					var arrayOut = [];
					for(var item in data){

						var newCfc = tryComplexObject(name, arrayType, item);
						if(isNull(newCfc)){
							return out;
						} else {
							arrayOut.append(newCfc);
						}

					}

					out.insert(name, arrayOut);
					return out;
				}

			} else {
				var newCfc = tryComplexObject(name, type, data);
				if(isNull(newCfc)){
					return out;
				} else {
					out.insert(name, newCfc);
					return out;
				}
			}

		}

		if(arrayLen(args) == 1 and !forceArgumentCollection){

			var name = args[1].name;
			var type = args[1].type;
			var required = args[1].required;

			return getArgumentValues(name=name, type=type, isRequired=required, data=data);

		} else {

			if(isStruct(data)){
				for(var arg in args){

					if(arg.type == "zeroFormState"){

						if(arg.keyExists("required") and arg.required){
							if(!request._zero.keyExists("zeroFormState")){
								throw("Could not load the form state but it was marked as required. Ensure that a form state is created before calling this controller function");
							}
							out.insert(arg.name, request._zero.zeroFormState);
							continue;
						} else {
							if(request._zero.keyExists("zeroFormState")){
								out.insert(arg.name, request._zero.zeroFormState);
							}
						}
					}

					if(arg.type == "zeroClient"){

						if(arg.keyExists("required") and arg.required){
							if(!request._zero.keyExists("zeroClient")){
								throw("Could not load the form state but it was marked as required. Ensure that a form state is created before calling this controller function");
							}
							out.insert(arg.name, request._zero.zeroClient);
							continue;
						} else {
							if(request._zero.keyExists("zeroClient")){
								out.insert(arg.name, request._zero.zeroClient);
							}
						}
					}


					if(data.keyExists(arg.name)){
						var populatedArg = getArgumentValues(name=arg.name, type=arg.type, isRequired=true, data=data[arg.name]);
						try {
							out.append(populatedArg);
						}catch(any e){
							writeDump(data);
							writeDump(arg);
							writeDump(local);
							abort;
						}
					} else {
						if(arg.keyExists("required") AND arg.required){
							addError(arg.name,{message:"The argument #arg.name# was required but was not passed in", original_value:data});
							return out;
						}
					}
				}
				// abort;
				return out;

			} else {
				addError(cfcName, {message:"The object #cfcName# has multiple arguments but the value passed is not a structure. This value should be passed as a struct", original_value:data});
				return out;
			}
		}

	}

	public function getMigration(){
		var migration = new migrator.model.migration(expandPath("/releases"), db.db);
		return migration;
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

		// writeDump(request.context);
		// abort;

		argsToPass = recurseFindCFCArguments(data=request.context, cfc=cfc, method=method, errors=request._zero.argumentErrors, forceArgumentCollection=true);
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
                		// var argsToPass = recurseFindCFCArguments(any data, cfc, method, errors=request._zero.argumentErrors)
                		if(!request._zero.argumentErrors.isEmpty()){
                			request._zero.controllerResult = {
                				"success":false,
                				"errors":request._zero.argumentErrors
                			}
            			} else {
	                		// request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = argsToPass)' );
	                		try {
	                			request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = argsToPass)' );
            				} catch(any e){

            					if(!e.errorCode == "0"){
									var errorcode = e.errorCode
								} else {
									var errorcode = "500";
								}

            					request._zero.controllerResult = {
	                				"success":false,
	                				"errors":{
	                					"#e.type#":e.message,
	                				},
	                				"status_code":errorCode
	                			}
            				}
            			}

                	} else {
                		try {
                		for(var key in request.context){
							var keyNoUnderscore = replaceNoCase(key,"_","","all");
							if(!request.context.keyExists(keyNoUnderscore)){
								request.context[keyNoUnderscore] = request.context[key];
							}
						}
	                	request._zero.controllerResult = evaluate( 'cfc.#method#( argumentCollection = request.context)' );

                		}catch(any e){
                			writeDump(request.context);
                			writeDump(e);
                			abort;
                		}
                		// request._zero.controllerResult = evaluate( 'cfc.#method#( rc = request.context, headers = request._fw1.headers )' );
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

    public zeroFormState function getZeroFormState(){
    	if(request._zero.keyExists("zeroFormState")){
    		return request._zero.zeroFormState;
    	} else {
    		throw("No zeroFormState was defined. Be sure there is a form state created before calling this function");
    	}
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

    private function installCustomFunctions(){

    	var webInfPath = expandPath("{lucee-web}");
    	var sourcePath = getDirectoryFromPath(getCurrentTemplatePath());
    	var paths = [
    		{
    			source:sourcePath&"/lib/print.cfc",
    			destination:webInfPath&"/library/function/print.cfc"
    		},
    		{
    			source:sourcePath&"/lib/print.cfm",
    			destination:webInfPath&"/library/function/print.cfm"
    		},
    	];

    	var didCopy = false;
    	for(var path in paths){
    		if(!fileExists(path.destination)){
    			fileCopy(path.source, path.destination);
    			didCopy = true;
    		}
    	}

    	if(didCopy){
    		throw("Zero installed custom functions to Lucee, please restart Lucee to continue");
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
		// writeDump(variables.framework.routes);
		// abort;
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

				//Add route for linking resource
				variables.framework.routes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/link*' = '/#nest#/link/#name#_id/:#nest#_id/id/:id' });

				//Add route for unlinking resource
				variables.framework.routes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/unlink*' = '/#nest#/unlink/#name#_id/:#nest#_id/id/:id' });
			}

			if(arrayLen(nested)){
				variables.framework.routes.prepend({ "$RESOURCES" = { resources = "#name#", nested="#nested.toList()#"} });
			} else {
				variables.framework.routes.prepend({ "$RESOURCES" = { resources = name} })
			}


		}
		return variables.framework.routes;
	}

	private array function loadSubsystemControllers(){
		// variables.framework.routes = [];
		var subsystems = directoryList(path=expandPath(variables.framework.base));

		for(var subsystem in subsystems){

			subsystemName = listLast(subsystem, server.separator.file);

			/**
			 * Routes for the default subsystem must be defined without the
			 * subsystem in the route in order for them work. This is
			 */
			if(variables.framework.defaultSubsystem == subsystemName){
				var controllers = directoryList(path="#subsystem#/controllers", filter="*.cfc");

				for(var controller in controllers){
					file = getFileFromPath(controller);
					name = listFirst(file, ".");
					//Runscrit Routes

					var meta = getComponentMetaData("#variables.framework.base#.#subsystemName#.controllers.#name#");
					var nested = listToArray(meta.nested?:"");
					for(var nest in nested){
						//Add nesting

						//Add route for linking resource
						variables.framework.routes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/link*' = '/#nest#/link/#name#_id/:#name#_id/id/:id' });

						//Add route for unlinking resource
						variables.framework.routes.prepend({'$POST/#name#/:#name#_id/#nest#/:id/unlink*' = '/#nest#/unlink/#name#_id/:#name#_id/id/:id' });
					}

					if(arrayLen(nested)){
						variables.framework.routes.prepend({ "$RESOURCES" = { resources = "#name#", nested="#nested.toList()#"} });
					} else {
						variables.framework.routes.prepend({ "$RESOURCES" = { resources = name } })
					}
				}

			} else {

				var controllers = directoryList(path="#subsystem#/controllers", filter="*.cfc");

				for(var controller in controllers){
					file = getFileFromPath(controller);
					name = listFirst(file, ".");

					//Runscrit Routes

					var meta = getComponentMetaData("#variables.framework.base#.#subsystemName#.controllers.#name#");
					var nested = listToArray(meta.nested?:"");
					for(var nest in nested){

						//Add route for linking resource
						variables.framework.routes.prepend({'$POST/#subsystemName#/#name#/:#name#_id/#nest#/:id/link*' = '/#subsystemName#:#nest#/link/#name#_id/:#name#_id/id/:id' });

						//Add route for unlinking resource
						variables.framework.routes.prepend({'$POST/#subsystemName#/#name#/:#name#_id/#nest#/:id/unlink*' = '/#subsystemName#:#nest#/unlink/#name#_id/:#name#_id/id/:id' });
					}
					if(arrayLen(nested)){
						variables.framework.routes.prepend({ "$RESOURCES" = { resources = "#name#", nested="#nested.toList()#", subsystem = subsystemName} });
					} else {
						variables.framework.routes.prepend({ "$RESOURCES" = { resources = name, subsystem = subsystemName } })
					}

					//Create a universal route for the subsystem to the subsystem name for SES urls
					variables.framework.routes.append({'/#subsystemName#*' = '/#subsystemName#:\1'});
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
		if(variables.zero.csrfPRotect){
			finalOutput = injectCSRFIntoForms(finalOutput);
		}

		if(variables.zero.validateHTMLOutput){
			// setupFrameworkDefaults();

			jsoup = createObject("java", "org.jsoup.Jsoup", "formcheck/jsoup-1.10.2.jar");
			var htmlDoc = jsoup.parse(finalOutput);
			var links = htmlDoc.select("a");
			var forms = htmlDoc.select("form");

			var routesFunc = function(link, routes, method){
				return this.processRoutes(arguments.link, arguments.routes, arguments.method);
			}

			var routes = variables.framework.routes;
			var interfaces = [
				"cfc",
				"cfcMethod",
				"formElement",
				"linkElement",
				"routes",
				"routesFunc",
				"htmlDoc",
				"validation",
				"urlArguments"
			]

			var implements = function(cfc, type){

				var metaData = getMetaData(cfc);
				if(metaData.keyExists("implements")){
					if(metaData.implements.keyExists(arguments.type)){
						return true;
					} else {
						writeDump(metaData);
						abort;
						return false;
					}

				} else {
					return false;
				}
			}
			// writeDump(links);
			var linkErrors = [];

			var validations = directoryList("formcheck/validations");

			for(var linkElement in links){

				for(var validation in validations){
					var file = listFirst(getFileFromPath(validation), ".");

					if(arrayFindNoCase(interfaces, file) == 0){
						var validator = createObject("formcheck.validations.#file#");

						if(isInstanceOf(validator, "validation") and isInstanceOf(validator,"linkElement")){

							var args = {};
							if(isInstanceOf(validator, "linkElement")){args.linkElement = linkElement}
							if(isInstanceOf(validator, "htmlDoc")){args.htmlDoc = htmlDoc}
							if(isInstanceOf(validator, "routes")){args.routes = routes}
							if(isInstanceOf(validator, "routesFunc")){args.routesFunc = routesFunc}

							try {

								validator.init(argumentCollection=args);
							} catch(any e){
								linkErrors.append({type:e.type, message:e.message, original:linkElement.toString()});
							}
						}
					}
				}
			}

			var formErrors = [];
			loopForm: for(var formElement in forms){

				for(var validation in validations){
					var file = listFirst(getFileFromPath(validation), ".");

					if(arrayFindNoCase(interfaces, file) == 0){

						var validator = createObject("formcheck.validations.#file#");

						if(isInstanceOf(validator, "validation") and isInstanceOf(validator, "formElement")){

							var args = {};
							if(isInstanceOf(validator, "formElement")){args.formElement = formElement}
							if(isInstanceOf(validator, "htmlDoc")){args.htmlDoc = htmlDoc}
							if(isInstanceOf(validator, "routes")){args.routes = routes}
							if(isInstanceOf(validator, "routesFunc")){args.routesFunc = routesFunc}

							if(isInstanceOf(validator, "cfc") or isInstanceOf(validator, "cfcMethod")){
								try {
									// new formCheck.validations.formRouteNotFound(routesFunc, formElement, routes);
									// new formCheck.validations.missingFormMethod(argumentCollection=args);

									if(formElement.hasAttr('action')){
										var action = formElement.attr('action');
										var action = listFirst(action,"?");
										var method = uCase(formElement.attr('method'));
										var newContext = getPathAction(pathInfo=action, cgiRequestMethod=method);
										writeDump(newContext);
										// abort;
										var action = newContext.action;
										var subsystem = listFirst(action, ":");
										var subAction = listLast(action, ":");
										var controller = listFirst(subAction, ".");
										var cfcMethod = listLast(subAction, ".");
										// writeDump(action);
										var cfc = getCachedController(subsystem, controller);


										if(isInstanceOf(validator, "cfc")){args.cfc = cfc}
										if(isInstanceOf(validator, "cfcMethod")){args.cfcMethod = cfcMethod}
										if(isInstanceOf(validator, "urlArguments")){
											var urlArgs = {};
											if(newContext.keyExists("id")){
												urlArgs.id = newContext.id;
											}
											args.urlArguments = urlArgs;
										}

										try {
											validator.init(argumentCollection=args);

										} catch(expression e){
											writeDump(args);
												writeDump(validator);
												writeDump(isInstanceOf(validator,""));
												writeDump(e);
												abort;
										} catch(any e){
											formErrors.append({type:e.type, message:e.message, original:formElement.toString()});
											continue loopForm;
										}
									} else {
										formErrors.append({type:"missingFormAction", message:"Forms must have an action attribute", original:formElement.toString()});
										continue loopForm;
									}


								} catch(expression e){
									writeDump(validator);
									writeDump(isInstanceOf(validator,""));
									writeDump(e);
									abort;
								} catch(any e){
									formErrors.append({type:e.type, message:e.message, original:formElement.toString()});
									continue loopForm;
								}


							} else {

								try {
									validator.init(argumentCollection=args);
								} catch(expression e){
										writeDump(validator);
										writeDump(isInstanceOf(validator,""));
										writeDump(e);
										abort;
								} catch(any e){
									formErrors.append({type:e.type, message:e.message, original:formElement.toString()});
									continue loopForm;
								}
							}

						}
					}
				}
			}

			if(linkErrors.len()){
				request._zero.linkErrors = linkErrors;
				writeDump(var=linkErrors, label="Zero detected the following bad links");
			}

			if(formErrors.len()){
				request._zero.formErrors = formErrors;
				writeDump(var=formErrors, label="Zero detected the following incorect forms");
			}
		}

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

	/* Duplicate and localize setupRequestDefaults() from one.cfc
	* so that we can pass in our own path info and get an action back
	* to manually check the controller
	*/
	private struct function getPathAction(pathInfo=request._fw1.cgiPathInfo,
                                    base=variables.framework.base,
                                    cfcbase=variables.framework.cfcbase,
                                    cgiScriptName=request._fw1.cgiScriptName,
                                    routes=variables.framework.routes,
                                    cgiRequestMethod=request._fw1.cgiRequestMethod) {

        var pathInfo = arguments.pathInfo;
        var base = arguments.base;
        var cfcbase = arguments.cfcbase;
        var cgiScriptName = arguments.cgiScriptName;
        var routes = arguments.routes;
        var cgiRequestMethod = arguments.cgiRequestMethod;

        if ( !structKeyExists(local, 'context') ) {
            local.context = { };
        }
        // SES URLs by popular request :)
        if ( len( pathInfo ) > len( cgiScriptName ) && left( pathInfo, len( cgiScriptName ) ) == cgiScriptName ) {
            // canonicalize for IIS:
            pathInfo = right( pathInfo, len( pathInfo ) - len( cgiScriptName ) );
        } else if ( len( pathInfo ) > 0 && pathInfo == left( cgiScriptName, len( pathInfo ) ) ) {
            // pathInfo is bogus so ignore it:
            pathInfo = '';
        }

        if ( arrayLen( routes ) ) {
            var routeMatch = processRoutes( pathInfo, routes, cgiRequestMethod );
            if ( routeMatch.matched ) {
                if ( variables.framework.routesCaseSensitive ) {
                    pathInfo = rereplace( routeMatch.path, routeMatch.pattern, routeMatch.target );
                } else {
                    pathInfo = rereplacenocase( routeMatch.path, routeMatch.pattern, routeMatch.target );
                }
                if ( routeMatch.redirect ) {
                    location( pathInfo, false, routeMatch.statusCode );
                } else {
                    local.route = routeMatch.route;
                }
            }
        } else if ( variables.framework.preflightOptions && local.cgiRequestMethod == "OPTIONS" ) {
            // non-route matching but we have OPTIONS support enabled
            local.routeMethodsMatched.get = true;
            local.routeMethodsMatched.post = true;
        }

        try {
            // we use .split() to handle empty items in pathInfo - we fallback to listToArray() on
            // any system that doesn't support .split() just in case (empty items won't work there!)
            if ( len( pathInfo ) > 1 ) {
                // Strip leading "/" if present.
                if ( left( pathInfo, 1 ) EQ '/' ) {
                    pathInfo = right( pathInfo, len( pathInfo ) - 1 );
                }
                pathInfo = pathInfo.split( '/' );
            } else {
                pathInfo = arrayNew( 1 );
            }
        } catch ( any exception ) {
            pathInfo = listToArray( pathInfo, '/' );
        }
        var sesN = arrayLen( pathInfo );
        if ( ( sesN > 0 || variables.framework.generateSES ) && getBaseURL() != 'useRequestURI' ) {
            local.generateSES = true;
        }
        for ( var sesIx = 1; sesIx <= sesN; sesIx = sesIx + 1 ) {
            if ( sesIx == 1 ) {
                local.context["action"] = pathInfo[sesIx];
            } else if ( sesIx == 2 ) {
                local.context["action"] = pathInfo[sesIx-1] & '.' & pathInfo[sesIx];
            } else if ( sesIx mod 2 == 1 ) {
                local.context[ pathInfo[sesIx] ] = '';
            } else {
                local.context[ pathInfo[sesIx-1] ] = pathInfo[sesIx];
            }
        }
        // certain remote calls do not have URL or form scope:
        if ( isDefined( 'URL'  ) ) structAppend( local.context, URL );
        if ( isDefined( 'form' ) ) structAppend( local.context, form );
        var httpData = getHttpRequestData();
        if ( variables.framework.enableJSONPOST ) {
            // thanks to Adam Tuttle and by proxy Jason Dean and Ray Camden for the
            // seed of this code, inspired by Taffy's basic deserialization
            var body = httpData.content;
            if ( isBinary( body ) ) body = charSetEncode( body, "utf-8" );
            if ( len( body ) ) {
                switch ( listFirst( CGI.CONTENT_TYPE, ';' ) ) {
                case "application/json":
                case "text/json":
                    try {
                        var bodyStruct = deserializeJSON( body );
                        structAppend( local.context, bodyStruct );
                    } catch ( any e ) {
                        throw( type = "FW1.JSONPOST",
                               message = "Content-Type implies JSON but could not deserialize body: " & e.message );
                    }
                    break;
                default:
                    // ignore -- either built-in (form handling) or unsupported
                    break;
                }
            }
        }
        local.headers = httpData.headers;
        // figure out the request action before restoring flash context:
        if ( !structKeyExists( local.context, "action" ) ) {
            local.context[ "action" ] = getFullyQualifiedAction( variables.framework.home );
        } else {
            local.context[ "action" ] = getFullyQualifiedAction( local.context[ "action" ] );
        }
        if ( variables.framework.noLowerCase ) {
            local.action = validateAction( local.context[ "action" ] );
        } else {
            local.action = validateAction( lCase(local.context[ "action" ]) );
        }
        local.requestDefaultsInitialized = true;
        return local.context;
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

	/**
	 * Wraps the print object and outputs the result	 *
	 */
	public function print(required any value=""){
		return new lib.print(arguments.value);
	}

	function onRequestStart(){
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


		writeLog(file="zero_trace", text="start onRequestStart()");
		variables.zero.throwOnNullControllerResult = variables.zero.throwOnNullControllerResult?: true;
		variables.zero.validateHTMLOutput = variables.zero.validateHTMLOutput?: false;
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

		if(application.zero.keyExists("routes") and variables.zero.cacheControllers){
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