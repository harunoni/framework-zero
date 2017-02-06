<cfscript>
path = cgi.path_info & ".cfm";
path = right(path, len(path) - 1);

//Setup blog framework variables
// template = getTemplateFromPath(path);
template = cgi.path_info;
request.template = listLast(template,"/");
request.title = request.template.replaceNoCase("-", " ", "all");
path = path.replaceNoCase("authors/","");
Blog = getBlog();

cleanPath = cgi.path_info.replaceNoCase("/authors", "");
if(!Blog.isValidCGIPath(cleanPath, "authors")){
	throw("Could not load that file #path#");
} else {

	savecontent variable="body" {
		blogData = "";
		module template="/tags/blog.cfc" variable="blogData" {
			var IncludePath = Blog.getIncludePathFromCGI(cleanPath, "authors");		
			include template = IncludePath.toString();		
		}			
	}

	Blog = getBlog();
	IncludePath = Blog.getTemplateIncludePath("views/authors/read.cfm");
	include template=IncludePath.toString();
}
</cfscript>