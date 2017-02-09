<!---
JS Loader for the ZeroTable progress indicator. Include this within your application or views to ensure that the javascript
files are loaded
--->
<cfparam name="request.require_js" default="false">
<cfif  request.require_js == false>	
	<cfsavecontent variable="htmlhead">
		<!-- Progress Indicator for Zero Ajax, added from zerotable.cfc-->
		<link href='/assets/vendor/nprogress-master/nprogress.css' rel='stylesheet' />
		<script src='/assets/vendor/nprogress-master/nprogress.js'></script>
	</cfsavecontent>
	<cfhtmlhead text="#htmlhead#"/>	
	<cfset request.require_js = true>
</cfif>