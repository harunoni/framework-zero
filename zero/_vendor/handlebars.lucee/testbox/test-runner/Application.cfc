/**
* Copyright Since 2005 Ortus Solutions, Corp
* www.ortussolutions.com
**************************************************************************************
*/
component{
	this.name = "A TestBox Runner " & hash( getCurrentTemplatePath() );
	// any other application.cfc stuff goes below:
	this.sessionManagement = true;

	// any mappings go here, we create one that points to the root called test.
	this.mappings[ "/test" ] = getDirectoryFromPath( getCurrentTemplatePath() );	
	this.mappings[ "/handle" ] = "c:\websites\handlebars.lucee";
	this.customTagPaths  = expandPath("/");
	// writeDump(expandPath("/"));
	// abort;
	// writeDump(expandPath("handle"));
	// abort;

	// any orm definitions go here.

	// request start
	public boolean function onRequestStart( String targetPage ){

		return true;
	}
}