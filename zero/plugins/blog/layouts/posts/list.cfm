<!---
Template includer for zero blog post list page
--->
<cfscript>
Blog = getBlog();
IncludePath = Blog.getTemplateIncludePath("layouts/posts/list.cfm");
include template=IncludePath.toString();
</cfscript>
