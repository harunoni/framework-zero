<cf_handlebars context="#rc#">
<div class="row">
    <div class="col-lg-12">
        <h1 class="page-header">Resources</h1>
    </div>
</div>

<div class="row">
    <div class="col-lg-12">
        <cf_handlebars context="#rc.data.resources#">
            <cfinclude template="/zerotable/views/main/table.hbs"/>
        </cf_handlebars>
    </div>
</div>

</cf_handlebars>