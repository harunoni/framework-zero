<style type="text/css">
	.btn-xxs {
		padding: 2px 4px;
		font-size: 10px;
	    line-height: 1.2;
	    border-radius: 0;
	}
</style>
<!--- <cfdump var="#rc#"> --->
<cf_handlebars context="#rc#">
<div class="row">
	<div class="col-lg-12">
		<h1 class="page-header">New User

		</h1>
		<ol class="breadcrumb">
			<li><a href="/">Home</a></li>
			<li><a href="/auth/users">Users</a></li>
			<li class="active">{{data.user.first_name}} {{data.user.last_name}}</li>
		</ol>
	</div>

</div>
<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">User Details</h3>
			</div>
			<div class="panel-body">
				<form action="/auth/users/{{data.user.id}}" method="POST" role="form">
					<input type="hidden" name="goto" value="/auth/users" />
					<input type="hidden" name="goto_fail" value="/auth/users/new" />
					<input type="hidden" name="preserve_response" value="view_state.create_user">
					{{#if view_state.create_user.errors}}
						<div class="alert alert-danger">
							There were errors trying to create the user
							<ul>
								{{#each view_state.create_user.errors.errors}}
									<li><strong>{{sentenceCase @key}}</strong>: {{message}}</li>
								{{/each}}
							</ul>
						</div>
					{{/if}}
					<div class="form-group">
						<label for="exampleInputEmail1">Email address</label>
						<input type="email" class="form-control" name="email_address" placeholder="Email" value="{{data.user.email_address}}" disabled="true">
					</div>
					<div class="form-group">
						<label for="exampleInputEmail1">First Name</label>
						<input class="form-control" name="first_name" placeholder="" value="{{data.user.first_name}}">
					</div>
					<div class="form-group">
						<label for="exampleInputEmail1">Last Name</label>
						<input class="form-control" name="last_name" placeholder="" value="{{data.user.last_name}}">
					</div>
					<div class="form-group">
						{{#if view_state.reset_password}}
							<div class="alert alert-warning">
								This will reset the users password and cannot be undone.
							</div>
							<label for="exampleInputPassword1">Password</label>
							<div class="input-group">
								<input type="password" class="form-control" name="password">
								<span class="input-group-btn">
									<button class="btn btn-primary">Update</button>
									<a class="btn btn-default" href="/auth/users/{{data.user.id}}/read">Cancel</a>
								</span>
							</div>
						{{else}}
							<label for="exampleInputPassword1">Password</label>
							<div class="input-group">
								<input type="password" class="form-control" name="password" disabled="true">
								<span class="input-group-btn">
									<button class="btn btn-default" name="submit_overload" formaction="/auth/users/{{data.user.id}}/read" value="{'view_state.reset_password':true, 'goto_before':'/auth/users/{{data.user.id}}', 'preserve_form':'true'}">Reset Password</button>
								</span>
								<span class="input-group-btn">
									<button class="btn btn-default" name="submit_overload" formaction="/auth/users/{{data.user.id}}/send_login" value="{}">Send Password Reset</button>
								</span>
							</div>
						{{/if}}
					</div>

					{{#if view_state.reset_password}}
					{{else}}
						<button type="submit" class="btn btn-primary">Save</button>
					{{/if}}
				</form>
			</div>
		</div>
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">Logins</h3>
			</div>
			<div class="panel-body table-responsive">
				<table class="table table-striped">
					<thead>
						<th>Created Date</th>
						<th>Expire Date</th>
						<th>Disable</th>
					</thead>
					<tbody>
						{{#each data.user.logins}}
							<tr>
								<td>{{created_date}}</td>
								<td>{{expire_date}}</td>
								<td>
								<!--- 	<form action="/auth/logins/{{id}}/delete" method="post">
										<button class="btn btn-sm btn-primary">Disable</button>
									</form> --->
								</td>
							</tr>
						{{/each}}
					</tbody>
				</table>
			</div>
		</div>
	</div>
</div>
<div class="row">
	<div class="col-lg-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">Available Roles</h3>
			</div>
			<div class="panel-body">
				{{#if data.user.available_roles}}
				<ul class="list-group">
					{{#each data.user.available_roles}}
						<li class="list-group-item">
							<h4 class="list-group-item-heading"><a href="/auth/roles/{{id}}">{{name}}</a>
								<form action="/auth/roles/{{id}}/users/{{data.user.id}}/link" method="post" style="display:inline;">
									<input type="hidden" name="goto" value="/auth/users/{{data.user.id}}">
									<input type="hidden" name="goto_fail" value="/auth/users/{{data.user.id}}">
									<input type="hidden" name="preserve_response" value="view_state.assign_role">
									<button class="btn btn-xs btn-primary pull-right">Assign Role</button>
								</form>
							</h4>
							<p class="list-group-item-text">{{description}}
							</p>
						</li>
					{{/each}}
				</ul>
				{{else}}
					No roles left available to assign, this user can do anything
				{{/if}}
			</div>
		</div>
	</div>
	<div class="col-lg-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">Assigned Roles
					{{#if data.user.roles}}
					<form action="/auth/users/{{id}}/read" method="post" style="display:inline">
						<input type="hidden" name="goto_before" value="/auth/users/{{data.user.id}}">
						<input type="hidden" name="preserve_form" value="true">
						<input type="hidden" name="view_state.show_role_resources" value="true">
						<button class="btn btn-xxs btn-primary pull-right">View Assigned Resources</button>
					</form>
					{{/if}}
				</h3>
			</div>
			<div class="panel-body">
				<ul class="list-group">
					{{#each data.user.roles}}
						<li class="list-group-item">
							<h4 class="list-group-item-heading"><a href="/auth/roles/{{id}}">{{name}}</a>
								<form action="/auth/roles/{{id}}/users/{{data.user.id}}/unlink" method="post" style="display:inline">
									<input type="hidden" name="goto" value="/auth/users/{{data.user.id}}">
									<button class="btn btn-xs btn-primary pull-right">Unassign</button>
								</form>
							</h4>
							<p class="list-group-item-text">{{description}}

							</p>
							{{#if view_state.show_role_resources}}
								<ul class="list-group" style="margin-top:6px;">
								{{#each resources}}
									<li class="list-group-item {{#unless user_active}}disabled{{/unless}}" ><strong>{{name}}</strong> <i>{{description}}</i>
										{{#if user_active}}
											<form action="/auth/resources/{{id}}/users/{{data.user.id}}/unlink" method="post" style="display:inline">
												<input type="hidden" name="goto" value="/auth/users/{{data.user.id}}">
												<input type="hidden" name="goto_fail" value="/auth/users/{{data.user.id}}">
												<input type="hidden" name="preserve_form" value="true">
												<input type="hidden" name="view_state.show_role_resources" value="true">
												<input type="hidden" name="preserve_response" value="view_state.remove_resource">
												<button class="btn btn-xxs btn-warning pull-right">Disable for this user</button>
											</form>
										{{else}}
											<form action="/auth/resources/{{id}}/users/{{data.user.id}}/link" method="post" style="display:inline">
												<input type="hidden" name="goto" value="/auth/users/{{data.user.id}}">
												<input type="hidden" name="goto_fail" value="/auth/users/{{data.user.id}}">
												<input type="hidden" name="view_state.show_role_resources" value="true">
												<input type="hidden" name="preserve_form" value="true">
												<input type="hidden" name="preserve_response" value="view_state.add_resource">
												<button class="btn btn-xxs btn-primary pull-right">Enable for this user</button>
											</form>
											<br /><strong>This resource permission has been disabled</strong>
										{{/if}}
									</li>

								{{/each}}

								</ul>
							{{/if}}

						</li>
					{{/each}}
				</ul>
			</div>
		</div>
	</div>
</div>

</cf_handlebars>