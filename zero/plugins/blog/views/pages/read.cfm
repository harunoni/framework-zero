<cfscript>
path = cgi.path_info & ".cfm";
path = right(path, len(path) - 1);

Blog = getBlog();

if(!Blog.isValidCGIPath(cgi.path_info, "pages")){
	throw("Could not load that file");
} else {	
	IncludePath = Blog.getIncludePathFromCGI(cgi.path_info, "pages");

	savecontent variable="body" {
		include template = IncludePath.toString();		
	}

	Blog = getBlog();
	IncludePath = Blog.getTemplateIncludePath("views/pages/read.cfm");
	include template=IncludePath.toString();
}
</cfscript>