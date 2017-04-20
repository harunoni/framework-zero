<cfoutput>
<h1 class="page-header">Accounts</h1>
<div style="margin-bottom:5px;">
	<!--- <a href="<!--- #rc.queryString.setValue("action","auth:accounts.edit").setValue("accountid","0").get()#--->" class="btn btn-primary btn-sm">Create New Account</a> --->
	<a id="createNew" href="#rc.queryString.getNew().setValues({subsystem:"auth",section="accounts",suffix:"new", "entityType":"accounts"}).get()#" class="btn btn-primary btn-sm">Create New Account</a> of type:
	<select id="accountType" onChange="Javascript: $('##createNew').attr('href', $('##createNew').attr('href').replace('entityType=' + $(this).attr('previousValue'), 'entityType=' + $(this).val()));" previousValue="accounts">
		<cfloop array="#rc.data.extendedEntities#" item="entity">
			<option value="#entity#">#entity#</option>
		</cfloop>
	</select>
</div>
<table class="table table-striped table-bordered table-hover">
	<thead>
		<tr>
			<th style="width:100px;">Actions</th>
			<th style="width:100px;">ID</th>
			<th>Account Name</th>
			<th>Address</th>
		</tr>
	</thead>
	<tbody>
		<cfloop array="#rc.data.accounts#" item="account">
			<tr>
				<td>
					<a href="#rc.queryString.getNew().setValues({subsystem:request.subsystem, section:request.section, id:account.id}).get()#"><i class="fa fa-edit"></i></a> 
					<!--- <a href="#rc.queryString.getNew().setValue("action","auth:accounts.delete_account").setValue("accountid",account.id).get()#" onClick="Javascript: var r = confirm("Are you sure?"); if(r!=true){false;}"><i class="fa fa-minus-circle"></i></a> --->
					<form name="delete_account_#account.id#" method="POST" style="display:inline;" action="#rc.queryString.getNew().setValues({subsystem:"auth",section:"accounts",id:account.id, suffix:"delete"}).get()#">
                                    <button class="linkSubmit" type="submit"><i class="fa fa-minus-circle"></i></button>
                                    <input type="hidden" name="goto" value="#rc.queryString.getNew().setValues({subsystem:"auth", section:"accounts", suffix:"list"}).get()#" />
                                </form>

				</td>
				<td>#account.id#</td>
				<td>#account.name#</td>
				<td>#account.address#</td>
			</tr>
		</cfloop>
	</tbody>

</table>
</cfoutput>