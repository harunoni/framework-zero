<cf_handlebars context="#rc#">
<div class="row">
    <div class="col-lg-12">
        <h1 class="page-header">Users
            <a href="/auth/users/new" class="btn btn-primary pull-right">Create New User</a>
        </h1>
    </div>
</div>

<div class="row">
    <div class="col-lg-12">
        <cf_handlebars context="#rc.data.users#">
            <cfinclude template="/zerotable/views/main/table.hbs"/>
        </cf_handlebars>
    </div>
</div>

</cf_handlebars>