<!--- <cfimport path="affiliates.core.utilities.ormToForm"> --->
<cfparam name="rc.entitytype" default="accounts">
<cfoutput>
<h1 class="page-header">#((rc.id == 0)?'New Account':'Edit Account')#</h1>

<cfif structKeyExists(rc,"message")>
    <div class="alert alert-success">#rc.message#</div>
</cfif>

<form role="form" method="post" action="/auth/accounts">
<input type="hidden" name="type" value="#rc.data.entityType#" />
<div class="panel panel-default">
    <div class="panel-heading">
        Account Settings
    </div>
    <!-- /.panel-heading -->
    <div class="panel-body">
        <!-- Nav tabs -->
        <ul class="nav nav-tabs">
            <li class="active"><a href="##settings" data-toggle="tab">Basic Settings</a>
            </li>
            <li><a href="##extended" data-toggle="tab">Extended Properties</a>
            </li>
            <li><a href="##permissions" data-toggle="tab">Permissions</a>
            </li>            
        </ul>

        <!-- Tab panes --><cfoutput></cfoutput>
        <div class="tab-content">
            <div class="tab-pane fade in active" id="settings">
                <h4>Account Settings</h4>
                    
                    <input type="hidden" name="entitytype" value="#rc.entityType#" />
                
                    
                    <!--- ACCOUNT NAME --->
                    <div class="form-group">
                        <label for="name">Account Name</label>
                        <input class="form-control" name="name" value="#rc.data.account.Name#">
                    </div>

                    <!--- ACCOUNT ADDRESS --->
                    <div class="form-group">
                        <label for="address">Address</label>
                        <input class="form-control" name="address" value="#rc.data.account.Address#">
                    </div>

                    <!--- ADMIN SERVER HOST ADDRESS --->
                    <div class="form-group">
                        <label for="address">Admin Server Host Address</label>
                        <input class="form-control" name="admin_server" value="#rc.data.account.Admin_Server#">
                    </div>

                    <!--- ADMIN ADMINISTRATOR PATH --->
                    <div class="form-group">
                        <label for="address">Adminitrator Application Path</label>
                        <input class="form-control" name="admin_path" value="#rc.data.account.Admin_Path#">
                    </div>

                    <!--- ACCOUNT TYPE --->
                    <div class="form-group">
                        <label for="type"></label>
                        <select class="form-control" name="type">
                            <option value="customer" #((rc.data.account.Type IS "customer")?"selected":"")#>Customer</option>
                            <option value="super" #((rc.data.account.Type IS "super")?"selected":"")#>Super User</option>                        
                        </select>
                    </div>
                    <button type="submit" class="btn btn-default" name="save">#((rc.id IS 0)?"Create":"Save")#</button>
                
            </div>
            <div class="tab-pane fade in" id="extended">
                <h4>Extended Properties</h4>                   

                    <cfloop array="#rc.data.customFields#" index="i" item="field">
                        
                        <div class="form-group">
                            <label for="name">Account #field.name#</label>
                            <input class="form-control" name="#field.field#" value="#rc.data.account[field.field]#">
                        </div>
                    </cfloop>

                    <button type="submit" class="btn btn-default" name="save">#((rc.id IS 0)?"Create":"Save")#</button>
                
            </div>
            <div class="tab-pane fade" id="permissions">
                
                    <div class="col-md-5">
                        <div class="row">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Resource</th>
                                        <th>Permission</th>
                                    </tr>
                                </thead>   
                                <tbody>
                                    <cfloop array="#rc.resources#" item="resource">
                                    <tr>
                                        <td>#resource.getName()#</td>
                                        <td>
                                            <input name="resourcenames.#resource.getId()#" value="#resource.getName()#" type="hidden">
                                            <select class="form-control" name="resourceids.#resource.getId()#">
                                                <option value="0">Disabled</option>
                                                <option value="1" #((structKeyExists(rc.data.account.resources,resource.getName()))?"selected":"")#>Allow</option>                        
                                            </select>
                                        </td>
                                    </tr>
                                     </cfloop>
                                </tbody>                    
                            </table>
                        </div>
                        <div class="row">
                            <button type="submit" class="btn btn-default btn-primary" name="save">#((rc.id IS 0)?"Create":"Save")#</button>
                        </div>
                    </div>
                
                
            </div>
            <div class="tab-pane fade" id="messages">
                <h4>Messages Tab</h4>
                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
            </div>
            <div class="tab-pane fade" id="settings">
                <h4>Settings Tab</h4>
                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>
            </div>
        </div>
    </div>
    <!-- /.panel-body -->
</div>
</form>
<!--- USERS --->
<cfif rc.id GT 0> <!--- Only display users if we are on a real account --->
    <div class="panel panel-default">
        <div class="panel-heading">
            Users
        </div>
        <!-- /.panel-heading -->
        <div class="panel-body">
            <div style="margin-bottom:5px;">
                <a href="#rc.queryString.getNew().setValues({subsystem:"auth",section:"accounts",id:rc.data.account.id,nested:"users",suffix:"new"}).get()#" class="btn btn-primary btn-sm">Create New User</a>
            </div>
            <table class="table table-striped table-bordered table-hover">
                <thead>
                    <tr>
                        <th>Actions</th>
                        <th>UserID</th>
                        <th>User Name</th>
                    </tr>
                </thead>
                <tbody>
                    <cfloop array="#rc.data.account.users#" item="user">
                        <tr>                            
                            <td>
                                <a href="#rc.queryString.getNew().setValues({subsystem:"auth",section:"users",id:user.id}).get()#"><i class="fa fa-edit"></i></a>
                                <form name="delete_user_#user.id#" method="POST" style="display:inline;" action="#rc.queryString.getNew().setValues({subsystem:"auth",section:"users",id:user.id, suffix:"delete"}).get()#">
                                    <button class="linkSubmit" type="submit"><i class="fa fa-minus-circle"></i></button>
                                    <input type="hidden" name="goto" value="#rc.queryString.getNew().setValues({subsystem:"auth", section:"accounts", id:rc.data.account.id}).get()#" />
                                </form>
                                <!--- <a href="" onClick="Javascript: var r = confirm("Are you sure?"); if(r!=true){false;}"><i ></i></a> --->
                            </td>                            
                            <td>#user.id#</td>
                            <td>#user.email.toString()#</td>
                        </tr>    
                    </cfloop>
                </tbody>
            </table>
        </div>
        <!-- /.panel-body -->
    </div>
</cfif>
</cfoutput>

