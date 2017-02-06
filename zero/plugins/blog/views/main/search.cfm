<cfscript>
Blog = getBlog();
IncludePath = Blog.getTemplateIncludePath("views/main/search.cfm");
include template=IncludePath.toString();
</cfscript>