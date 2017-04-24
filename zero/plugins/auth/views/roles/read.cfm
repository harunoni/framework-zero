<cfscript>

param name="rc.view_state.show_child_resources" default="0" hint="Whether to show the child resources for a resource, will be passed in";
//Decorate resources if we should show its children
//based on the value of view_state.show_child_resources
for(var resource in rc.data.all_resources){

	var recurseChildren = function(resource){

		var resource = arguments.resource;
		resource["show_child_resources"] = true;
		for(var child in resource.children){
			recurseChildren(child);
		}
	}

	if(resource.id == rc.view_state.show_child_resources){
		recurseChildren(resource);
	}
}
</cfscript>
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
					{{#each data.all_resources}}
						<li class="list-group-item">
							<h4 class="list-group-item-heading">{{name}}

								{{#if is_enabled}}
									<form action="/auth/roles/{{data.role.id}}/resources/{{id}}/unlink" method="post" style="display:inline;">
										<input type="hidden" name="goto" value="/auth/roles/{{data.role.id}}">
										<button class="btn btn-xs btn-warning pull-right">Disable</button>
									</form>
								{{else}}
									<form action="/auth/roles/{{data.role.id}}/resources/{{id}}/link" method="post" style="display:inline;">
										<input type="hidden" name="goto" value="/auth/roles/{{data.role.id}}">
										<button class="btn btn-xs btn-primary pull-right">Enable</button>
									</form>
								{{/if}}
								<form action="/auth/roles/{{data.role.id}}/read" method="post" style="display:inline;">
									{{#if show_child_resources}}
										<button class="btn btn-xs btn-primary pull-right" style="margin-right:3px;">Hide Sub Resources</button>
									{{else}}
										<input type="hidden" name="view_state.show_child_resources" value="{{id}}">
										<button class="btn btn-xs btn-primary pull-right" style="margin-right:3px;">View Sub Resources</button>
									{{/if}}
								</form>
							</h4>
							<p class="list-group-item-text">{{description}}
								{{#*inline "childResources"}}
									<ul class="list-group" style="margin-top:8px;">
										{{#each this}}
									  	<li class="list-group-item">
											<h4 class="list-group-item-heading">{{name}}
												{{#if is_enabled}}
													<form action="/auth/roles/{{data.role.id}}/resources/{{id}}/unlink" method="post" style="display:inline;">
														<input type="hidden" name="goto" value="/auth/roles/{{data.role.id}}">
														<button class="btn btn-xs btn-warning pull-right">Disable</button>
													</form>
												{{else}}
													{{#if is_disabled}}
														<button class="btn btn-xs btn-default pull-right" data-toggle="tooltip" data-placement="top" title="A parent resource is already applied thus this is active. To enable only a sub resource, disable the parent resource first.">Active</button>
													{{else}}
														<form action="/auth/roles/{{data.role.id}}/resources/{{id}}/link" method="post" style="display:inline;">
															<input type="hidden" name="goto" value="/auth/roles/{{data.role.id}}">
															<button class="btn btn-xs btn-primary pull-right">Enable</button>
														</form>
													{{/if}}
												{{/if}}
											</h4>
											<p class="list-group-item-text">{{description}}
												{{#if show_child_resources}}
													{{> childResources children}}
												{{/if}}
											</p>
										</li>
										{{/each}}
									</ul>
								{{/inline}}

								{{#if show_child_resources}}
									{{> childResources children}}
								{{/if}}
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
				<h3 class="panel-title">Users with <strong>{{capitalCase data.role.name}}</strong> Role</h3>
			</div>
			<div class="panel-body">
				<ul class="list-group">
					{{#each data.role.users}}
						<li class="list-group-item">
							<h4 class="list-group-item-heading"><a href="/auth/users/{{id}}">{{email_address}}</a>
								<form action="/auth/roles/{{data.role.id}}/users/{{id}}/unlink" method="post" style="display:inline;">
									<input type="hidden" name="goto" value="/auth/roles/{{data.role.id}}">
									<button class="btn btn-xs btn-primary pull-right" data-toggle="tooltip" data-placement="top" title="This will remove the role from this user, this cannot be undone.">Remove Role</button>
								</form>
							</h4>
							<p class="list-group-item-text">{{first_name}} {{last_name}}
							</p>
						</li>
					{{/each}}
				</ul>
			</div>
		</div>
	</div>

</div>

</cf_handlebars>