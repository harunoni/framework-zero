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

</cf_handlebars>