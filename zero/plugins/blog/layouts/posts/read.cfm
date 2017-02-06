<!---
Template includer for zero blog post list page
--->
<cfscript>
Blog = getBlog();
IncludePath = Blog.getTemplateIncludePath("layouts/posts/read.cfm");
include template=IncludePath.toString();
</cfscript>