<!--- <cfdump var="#rc#"> --->
<cf_handlebars context="#rc#">
<div class="row">
	<div class="col-lg-12">
		<h1 class="page-header">Edit {{data.role.name}}

		</h1>
		<ol class="breadcrumb">
			<li><a href="/">Home</a></li>
			<li><a href="/auth/roles">Roles</a></li>
			<li class="active">{{data.role.name}}</li>
		</ol>
	</div>

</div>
<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">Role Basics</h3>
			</div>
			<div class="panel-body">
				<form action="/auth/roles/{{data.role.id}}" method="POST" role="form">
					<input type="hidden" name="goto" value="/auth/roles/{{data.role.id}}" />
					<input type="hidden" name="goto_fail" value="/auth/roles/new" />
					<input type="hidden" name="preserve_response" value="view_state.create_role">
					{{#if view_state.create_role.errors}}
						<div class="alert alert-danger">
							There were errors trying to create the role
							<ul>
								{{#each view_state.create_role.errors.errors}}
									<li><strong>{{sentenceCase @key}}</strong>: {{message}}</li>
								{{/each}}
							</ul>
						</div>
					{{/if}}
					<div class="form-group">
						<label for="exampleInputEmail1">Role Name</label>
						<input class="form-control" name="name" placeholder="" value="{{data.role.name}}">
					</div>
					<div class="form-group">
						<label for="exampleInputEmail1">Role Description</label>
						<input class="form-control" name="description" placeholder="" value="{{data.role.description}}">
					</div>
					<button type="submit" class="btn btn-primary">Save</button>
				</form>
			</div>
		</div>
	</div>
</div>
<div class="row">
	<div class="col-lg-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">Available Resources</h3>
			</div>
			<div class="panel-body">
				<ul class="list-group">
					{{#each data.role.available_resources}}
						<li class="list-group-item">
							<h4 class="list-group-item-heading">{{name}}
								<form action="/auth/roles/{{data.role.id}}/resources/{{id}}/link" method="post">
									<input type="hidden" name="goto" value="/auth/roles/{{data.role.id}}">
									<button class="btn btn-xs btn-primary pull-right">Add</button>
								</form>
							</h4>
							<p class="list-group-item-text">{{description}}
							</p>
						</li>
					{{/each}}
				</ul>

			</div>
		</div>
	</div>
	<div class="col-lg-6">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">Assigned Resources</h3>
			</div>
			<div class="panel-body">
				<ul class="list-group">
					{{#each data.role.resources}}
						<li class="list-group-item">
							<h4 class="list-group-item-heading">{{name}}
								<form action="/auth/roles/{{data.role.id}}/resources/{{id}}/unlink" method="post">
									<input type="hidden" name="goto" value="/auth/roles/{{data.role.id}}">
									<button class="btn btn-xs btn-primary pull-right">Remove</button>
								</form>
							</h4>
							<p class="list-group-item-text">{{description}}
							</p>
						</li>
					{{/each}}
				</ul>
			</div>
		</div>
	</div>

</div>

</cf_handlebars>