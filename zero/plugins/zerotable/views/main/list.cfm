<cfscript>
// rc.data["use_zero_ajax"] = false;
</cfscript>
<style>
.edit-link span {
    visibility: hidden;
}

.edit-link:hover span {
    visibility: visible;
}

.outerx {
  overflow: hidden;
}

.helperx {
  width: 1px;
  height: 100%;
  float: left;
}

.innerx {
  /*float: left;*/
}
</style>

<cfset zeroTableContext = request.zeroTableContext?:rc.data>
<cf_handlebars context="#zeroTableContext#">
<cfinclude template="table.hbs" />

{{#if use_zero_ajax}}
	<script>
	NProgress.configure({ parent: "#zerotable{{table_name}}", showSpinner: false });

	$( document ).ajaxStart(function() {
		NProgress.start();
	  // $( "#loading" ).show();
	}).ajaxStop(function() {
		NProgress.done();
	  // $( "#loading" ).hide();
	});
	</script>
{{/if}}
</cf_handlebars>