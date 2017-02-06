<cfscript>
path = cgi.path_info & ".cfm";
path = right(path, len(path) - 1);

//Setup blog framework variables
// template = getTemplateFromPath(path);
template = cgi.path_info;
request.template = listLast(template,"/");
request.title = request.template.replaceNoCase("-", " ", "all");
var Blog = getBlog();

if(!Blog.isValidCGIPath(cgi.path_info)){
	throw("Could not load that file #path#");
} else {
	var includePath = Blog.getIncludePathFromCGI(cgi.path_info);
	blogData = "";

	savecontent variable="body"{
		module template="/tags/blog.cfc" variable="blogData" {
			include template = IncludePath.toString();		
		}			
	}

	Blog = getBlog();
	IncludePath = Blog.getTemplateIncludePath("views/posts/read.cfm");
	include template=IncludePath.toString();
}
</cfscript>