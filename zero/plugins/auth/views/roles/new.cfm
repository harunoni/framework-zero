<cfdump var="#rc#">
<cf_handlebars context="#rc#">
<div class="row">
    <div class="col-lg-12">
        <h1 class="page-header">New Role
        </h1>
    </div>
</div>
<div class="row">
    <div class="col-lg-12">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">Role Basics</h3>
            </div>
            <div class="panel-body">
                <form action="/auth/roles" method="POST" role="form">
                    <input type="hidden" name="goto" value="/auth/roles" />
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
                        <label for="exampleInputEmail1">Description</label>
                        <input class="form-control" name="description" placeholder="" value="{{data.role.description}}">
                    </div>
                    <button type="submit" class="btn btn-default">Submit</button>
                </form>
            </div>
        </div>
    </div>
</div>

</cf_handlebars>