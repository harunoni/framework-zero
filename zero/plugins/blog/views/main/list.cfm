<!--- <cfdump var="#rc#"> --->
<cf_handlebars context="#rc#">
{{#each data.articles}}
  <h2><span style="text-transform: capitalize;"><a href="{{{canonical_url}}}">{{{title}}}</a></span> <small class="text-gray" style="font-size:.5em;">{{{published_date}}} &#9642; by {{author.name}}</small></h2>  
  <div class="clearfix"></div>
  <p>
    {{{summary}}}
  </p>
  <div style="margin-top:20px;">
    <a type="button" class="btn btn-outline btn-sm btn-default" href="{{{canonical_url}}}">Read More</a>

    <div class="pull-right"><i>In</i>: &nbsp;&nbsp;
      {{#each tags}}
        <button class="btn btn-xs btn-default">{{tag}}</button>
      {{/each}}
    </div>
    
  </div>
{{/each}}
</cf_handlebars>