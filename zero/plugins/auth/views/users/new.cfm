<!--- <cfdump var="#rc#"> --->
<cf_handlebars context="#rc#">
<div class="row">
    <div class="col-lg-12">
        <h1 class="page-header">New User
        </h1>
    </div>
</div>
<div class="row">
    <div class="col-lg-12">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h3 class="panel-title">User Details</h3>
            </div>
            <div class="panel-body">
                <form action="/auth/users" method="POST" role="form">
                    <input type="hidden" name="goto" value="/auth/users/:data.user.id" />
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
                        <input type="email" class="form-control" name="email_address" placeholder="Email" value="{{data.user.email_address}}">
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
                        <label for="exampleInputPassword1">Password</label>
                        <input type="password" class="form-control" name="password">
                    </div>
                    <button type="submit" class="btn btn-default">Submit</button>
                </form>
            </div>
        </div>
    </div>
</div>

</cf_handlebars>