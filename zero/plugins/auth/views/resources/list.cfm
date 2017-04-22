<cf_handlebars context="#rc#">
<div class="row">
    <div class="col-lg-12">
        <h1 class="page-header">Resources</h1>
    </div>
</div>

{{#*inline "parent"}}
	<ul class="list-group">
		{{#each this}}
			<li class="list-group-item">
				<h4 class="list-group-item-heading">{{name}}
				</h4>
				<p class="list-group-item-text">{{description}}
					{{#if children}}
						<!--- {{> parent children}} --->
					{{/if}}
				</p>
			</li>
		{{/each}}
	</ul>
{{/inline}}

<!--- {{#*inline "parent2"}}
	<div class="panel-group" id="accordion{{accord}}" role="tablist" aria-multiselectable="true">

		{{accord}}
		{{#each resourceitems}}
		<div class="panel panel-default">
			<div class="panel-heading" role="tab" id="headingOne{{@index}}">
				<h4 class="panel-title">
					<a role="button" data-toggle="collapse" data-parent="#accordion{{accord}}" href="#collapseOne{{@index}}" aria-expanded="true" aria-controls="collapseOne{{@index}}">
						{{name}}
					</a>
				</h4>
			</div>
			<div id="collapseOne{{@index}}" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne{{@index}}">
				<div class="panel-body">{{description}}
					{{#if children}}
						{{> parent2 resourceitems=children accord=id}}
					{{/if}}
				</div>
			</div>
		</div>
		{{/each}}
	</div>
{{/inline}} --->

<div class="row">
	<div class="col-lg-12">
		{{> parent data.root_resources}}
	</div>
</div>

<!--- <div class="row">
    <div class="col-lg-12">
        <cf_handlebars context="#rc.data.resources#">
            <cfinclude template="/zerotable/views/main/table.hbs"/>
        </cf_handlebars>
    </div>
</div> --->

</cf_handlebars>