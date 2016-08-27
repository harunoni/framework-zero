# framework-zero
**A lightweight RESTful web app and microservice framework for Lucee**

Zero is inspired by the [Framework-one (fw/1)](https://github.com/framework-one/fw1). Zero, however seeks to provde a better experience for type checked, RESTful and domain driven applications. Zero is based on Fw/1 and requires it, however diverges by removing dependency injection, changing the way controllers are executed, providing a cleaner RESTful experience out of the box, test first design, and specific defaults. In the future, Zero may be standalone, but fw/1 is very well designed for a number of things that are useful. 

##Zero Opinions
(That is, the opinions of Zero...)
Zero was designed with these goals in mind:

1. MVC is the Application layer in a Domain Driven Design. This means that controllers should deal only with HTTP request and Response values. All business logic exists within the Domain Model. 
2. Controllers should be testable and rely on the Lucee type system.
3. Easy RESTful & API Applications
4. Modern Web Application Defaults

####MVC as the Appliation Layer
In Zero, the M in MVC stands for the View Model. The actual domain model is outside of the Zero application. This contrasts with traditional monolithic MVC apps where the models, services, controllers and views all form the entire software package. Zero is only concerned with HTTP request and responses, and translating those into the calls of the actual domain model, via the controllers. While this is possible in a traditional MVC architecute like fw/1, the conventions lend themselves to the business domain model bleeding into the application layer.

In fact, there is no models folder in Zero. For simple applications, no view models will be necessary, the controllers will return the specific data the views need, and you call it a day. The domain model, (which lives outside the web application) has all of the services and models it needs to operate. Again, from the perspective of Zero, it is an HTTP application communicating with the underlying domain. It should be simple.

####Testable Controllers

Zero makes controllers and views explicit and testable by the following:

1. Disuade use of "global" scopes like the RC (request context). Controllers should receive certain values, and return certain values, for use by the views.
2. Use arguments of a controller function to check for existence of URL & FORM variables, and return specific variables for use by the views. Views should only have access to the values returned by the controller.

####Easy RESTfull & API Applications
Zero deploys with a resource based HTML and JSON enabled setup to enable dual HTML And JSON based applications. In zero, each resource endpoint will return either HTML views, or JSON, depending on the file extension (.json returns json).

#Differences from Framework One Fw/1
Zero is based on FW/1. For brevity, all of the features of FW/1 are available and work as advertised, except for these differences below. Zero is based on FW/1, but overrides key functionality.

###Easy HTML & JSON Application
Zero was created for the type of application where both the HTML client and API client can utilize the same code base. This is common for Resource based architectures. HTML clients work with the resources via GETs & POSTS, and API based clients (Javascript or otherwise) can optionally utilize all of the HTTP verbs (POST/DELETE/GET).

Zero checks every request for the presence of .json at the end of the resource. If present, Zero will serialize and return the data result from controllers and abort calling the view. Without .json present, Zero defaults to the HTML view. 

###Request Lifecycle
In zero, there are three lifecycle methods: request(), result() and response(). Request is for handling incoming HTTP request variables and optionally changing them. Result is for optionally handling the data returned from a controller execution. And response is for optionally handling the final text output to be returned by Zero.

```
public struct function request( rc ){
	return rc;
}
```

```
public any function result( controllerResult ){				
	return controllerResult;
}
```

```
public string function response( string response ){		
	return response;		
}		
```

####Controller Request() & Result()
Each controller can optionally have request() & result() methods matching the signatures above
The important difference with Zero is it disuades the use of the global request scope, and favors explicity passing variables along to the methods that require them.

###Controller Arguments
In Zero, controllers only receive the request parameters (url and form) for the arguments that they are explicityly expecting. The RC scope is not passed to the controller, instead Zero looks at the arguments and only passes the parameters the controller defines. The controller can therefore define required, optional and default values and only the right values will be passed. This allows you to use the Lucee type system to enforce access to your controllers, instead of having to handle for the existence of parameters manually.

Zero will also remove any underscores from snake_case FORM/URL variables when inspecting what arguments to pass to controllers. This Allows Lucee developers to easily continue to use camelCase convention in Lucee, but display snake_case in API and HTML documents, which is more conventional.

###Default Routes
Zero is designed for a RESTful applications by default (both HTML and JSON content resources), thus it creates resource routes for every controller by default. The default routes it creates for each controller are:

```
variables.framework.resourceRouteTemplates = [
	  { method = 'list', httpMethods = [ '$GET' ] },
	  { method = 'list', httpMethods = [ '$POST' ], routeSuffix = '/list' },
	  { method = 'new', httpMethods = [ '$GET', '$POST' ], routeSuffix = '/new' },
	  { method = 'create', httpMethods = [ '$POST' ] },
	  { method = 'read', httpMethods = [ '$GET' ], includeId = true },
	  { method = 'read', httpMethods = [ '$POST' ], includeId = true, routeSuffix = '/read' },
	  { method = 'update', httpMethods = [ '$PUT','$PATCH', '$POST' ], includeId = true },
	  { method = 'delete', httpMethods = [ '$DELETE' ], includeId = true },
	  { method = 'delete', httpMethods = [ '$POST' ], includeId = true, routeSuffic = '/delete' }
	];
```

Zero also changes the behavior of the routed by allowing a POST with suffixes. This is useful for when HTML forms can POST to endpoints which either take a PUT, or need to change the output of the view. For example, and HTML form POST to /list will allow the controller to change aspects of the view data.

#Zero's Unique Features
###HTML 5 Nested Form Support
HTML 5 Spec allows nesting form elements or making submit buttons go to different actions. This makes building RESTful server-size rendered HTML very easy and intuitive. However, no version of internet explorer supports nested forms yet. Zero provides a convention for mimicing HTML 5 forms by overloading the form scope with all of the forms values on the page, and then choosing the correct controller action.

###Utilize HTML & The Browser to control state
Zero encourages pushing all client state to the HTML or client data store. This is unconventional for Lucee application which typically store client state in the session scope. But by pushing state control to the client, it greatly simplifies controller code. Zero provides a number of state management features:

* goto
* preserve_response
* submit_overload

####Goto
Zero follows the Post-Redirect-Get convention wherein the browser should be making mutating changes with a post, and then redirect the user to a safe GET url. GETs should almost never mutate the state of the application. However when builind RESTful HTML post, where the user should be redirected to can vary. Therefore we leave this up to the client to decide. Zero will look for a "goto" form parameter on posts and redirect here if provided. 

`<input type="hidden" name="goto" value="{{url to go to after post}}"/>`

####Preserve Response
When posting to a resource and redirecting back to a resource, sometimes the results of that post need to be displayed on the subsequent get. Zero makes this possible by telling it to preserve the response of the goto.

`<input type="hidden" name="preserve_response" value="{{name of the variable to call the response}}"/>`

####Form Submission Overload
HTML 5 forms can submit to different endpoints by using the formaction feature `<button formaction="/someurl">`. However, sometimes when submitting to a different endpoint than the form normally submits to, you may want to pass in additional variables. For example, consider the following form which creates a customer and then redirects back to the customer list:

```
<h1>Customer Create Form</h1>
<form method="post" action="/customers">
	<!-- Redirect back to the customer's list -->
	<input type="hidden" name="goto" value="/customers">

	<label>Customer Name</label>
	<input type="text" name="customer_name" />
	<label>Company</label>
	<select name="company_id">
		<option value="1">Foobars LLC</option>
		<option value="2">Bazpops Inc.</option>
	</select>
	<button>Create</button>
</form>
```

Lets say that we want to add to this customer form a subform which can optionally create an account or select. The creation should post to the accounts endpoint, and then bring us back to the form to select that account to create the customer:

```
<h1>Customer CreateWith Account Form</h1>
<!-- Form is on /customer/create -->
<form method="post" action="/customers">
	<!-- Redirect back to the customer's list -->
	<input type="hidden" name="goto" value="/customers">
	
	<label>Customer Name</label>
	<input type="text" name="customer_name" />
	<button>Create</button>
	
	<label>Company</label>
	<select name="company_id">
		<option value="1">Foobars LLC</option>
		<option value="2">Bazpops Inc.</option>
	</select>
	<h3>Create Account</h3>
	<div>
		Or Create Account:
		<label>Account Name</label>
		<input type="text" name="account_name"/>
		<button formaction="/accounts" name="submit_overload" value="{goto:'customers/create'}">Create Account</button>		
	</div>
</form>
```

The value of the submit_overload button must be json and will be evaluated by Zero as if they were submitted form values `<button formaction="/accounts" name="submit_overload" value="{goto:'customers/create'}">Create Account</button>`, thus in this example, the account creation button overrides the goto variable of the parent form and redirects back tot he customer create form.


#Deployment
There are two methods to deploy framework-zero: standalone, and multi-site.

This repository is the standalone version, for the multi-site version, see [framework-zero-multi](https://github.com/roryl/framework-zero-multi)
