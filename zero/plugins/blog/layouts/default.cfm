<!---
Template includer for zero blog post list page
--->
<cfscript>
Blog = getBlog();
IncludePath = Blog.getTemplateIncludePath("layouts/default.cfm");
include template=IncludePath.toString();
</cfscript>
