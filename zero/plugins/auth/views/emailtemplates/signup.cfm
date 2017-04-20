<!--- HTML Content --->
<cfsavecontent variable="variables.htmlcontent">
<cfoutput>
Hello #variables.data.FirstName#,
<br /><br />
Your administrator has created a login for you at #variables.data.appName#. In order to set your password, please click this temporary link:

<br />
<br />
<a href="http://#variables.data.adminServer#/auth/logins/#variables.data.userToken#:#variables.data.passcode#">Login to #variables.data.appName#</a>
<br />
<br />
Regards,
The #variables.data.appName# team.
</cfoutput>
</cfsavecontent>

<!--- Plain Content ---->
<cfset variables.plaincontent = stripHTML(variables.htmlcontent)>