<cfscript>
rc.data["use_zero_ajax"] = true;
</cfscript>
<style>
.edit-link span {
    visibility: hidden;
}

.edit-link:hover span {
    visibility: visible;
}

.outerx {
  overflow: hidden;
}

.helperx {
  width: 1px;
  height: 100%;
  float: left;
}

.innerx {
  /*float: left;*/
}	
</style>
<cf_handlebars context="#rc.data#">

{{#*inline "zeroSelect"}}
	<div class="form-group">
		<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
		<select name="{{column_name}}" class="form-control">
			{{#each column_type.options}}
				{{#select (lookup ../this column_name)}}<option value="{{id}}">{{name}}</option>{{/select}}
			{{/each}}
		</select>
		{{#unless hide_buttons}}	
		<button class="btn btn-primary btn-sm">save</button>
		<a class="btn btn-default btn-sm" href="{{clear_edit_link}}">cancel</a>
		{{/unless}}
	</div>
{{/inline}}

{{#*inline "zeroSelectForm"}}
<form id="data-grid-form-name{{../id}}" action="{{base_path}}/{{../id}}" method="post" class="form-inline" style="display:inline;" {{#if use_zero_ajax}}zero-target="#zero-grid"{{/if}}>
	{{> zeroSelect}}
</form>
{{/inline}}




<div class="row" id="tableOutput">
	<div class="col-lg-12">
		<h1>Zero Table</h1>
		<div class="row" style="margin-bottom:10px;">
			<div class="col-lg-12">
								
			</div>
		</div>
		<div class="row" style="margin-bottom:10px;">
			<div class="col-lg-8">
				<form action="" method="get" class="form-inline" <!--- zero-submit-onchange="true" zero-target="#tableOutput" ---> <!--- zero-target="body" --->>
					{{#each current_params}}
						{{#unless is_max}}
							<input type="hidden" name="{{name}}" value="{{value}}">
						{{/unless}}
					{{/each}}			
					<div class="form-group">
						<label>Show </label>
						<select class="form-control" name="max">
							{{#select pagination.max}}<option value="10">10</option>{{/select}}
							{{#select pagination.max}}<option value="25">25</option>{{/select}}
							{{#select pagination.max}}<option value="50">50</option>{{/select}}
							{{#select pagination.max}}<option value="100">100</option>{{/select}}
							{{#select pagination.max}}<option value="200">200</option>{{/select}}
							{{#select pagination.max}}<option value="All">All</option>{{/select}}
						</select>
						<label>records</label>
					</div>
					<button class="btn btn-primary">Go</button>
				</form>
				<!--- <form method="get" action="/table" class="form-inline" style="display:inline;">
					<div class="form-group">
						<input name="name" type="text" class="form-control input-sm"> 
						<button class="btn btn-primary btn-sm">filter</button>									
					</div>
				</form>				
				<form method="get" action="/table" class="form-inline" style="display:inline;">
					<div class="form-group">
						<select class="form-control input-sm">
							<option value=""></option>
						</select>									
						<button class="btn btn-primary btn-sm">Select Category</button>									
					</div>
				</form>		 --->		
			</div>
			<div class="col-lg-4 text-right">
				<div class="form-group" class="pull-right" style="display:inline;">
					<form id="search-form" method="get" action="{{base_path}}" class="form-inline" style="display:inline;" zero-target="#zero-grid">
						{{#each current_params}}
							{{#unless is_search}}
								<input type="hidden" name="{{name}}" value="{{value}}">
							{{/unless}}
						{{/each}}						
						<input name="search" type="text" class="form-control input-sm" value="{{search}}"> 
						<button class="btn btn-primary btn-sm">Search</button>								
					</form>					
					<script>
						var searchForm = $('#search-form');
						var searchInput = $('#search-form > input[name="search"]');
						isTimeout = false;
						searchInput.on('keyup', function(event){
							// console.log(event);						
							// if(typeof timeout !== 'undefined'){
							if(isTimeout){
								// console.log(timeout);
								console.log('timeout found');
								// clearTimeout(timeout);								
							
							} else {

								isTimeout = true;
								timeout = setTimeout(function(){

									var prior = searchInput.val();
									var newKey = event.key;
									searchInput.attr('value', prior + newKey);
									var strLength = searchInput.val().length * 2;
									searchInput.focus();
									searchInput[0].setSelectionRange(strLength, strLength);

									event.preventDefault();
									searchForm.submit();

								}, 500); 							
								isTimeout = false;
							}
							
						});
					</script>
					{{#if search}}
						<script>
							var searchInput = $('#search-form > input[name="search"]');
							searchInput.focus();
							var strLength = searchInput.val().length * 2;
							searchInput.focus();
							searchInput[0].setSelectionRange(strLength, strLength);
						</script>
					{{/if}}					
					<a class="btn btn-default btn-sm" href="{{clear_search_link}}">Clear</a>					
				</div>
			</div>
		</div>
		<div id="zero-grid">
			<div class="row">
				<div class="col-lg-12">
					<table class="table table-bordered" >
			  			<thead>		  				
							{{#each columns}}							
								<th>{{friendly_name}}
									
									<!--- {{#if filterable}}
										<form action="{{current_link}}" method="get" class="form-inline" style="display:inline;">
											<input type="hidden" name="filter_column" value={{column_name}}>
											<select name="filter" class="input input-sm" style="padding:0px; height:22px;">
												{{#each filter}}
													<option value="{{id}}">{{name}}</option>
												{{/each}}										
											</select>
											<button class="btn btn-default btn-xs">filter</button>
										</form>
									{{/if}} --->
									{{#if is_sorted}}
										{{#if is_sorted_asc}}
											<span class="pull-right"><a href="{{sort_desc_link}}"><i class="fa fa-fw fa-sort-desc"></i></a></span>
										{{else}}
											<span class="pull-right"><a href="{{sort_asc_link}}"><i class="fa fa-fw fa-sort-asc"></i></a></span>
										{{/if}}
									{{else}}
										<span class="pull-right"><a href="{{sort_asc_link}}"><i class="fa fa-fw fa-sort"></i></a></span>
									{{/if}}
										<!--- <span class="pull-right"><a href=""><i class="fa fa-fw fa-filter"></i></a></span>
										<span class="pull-right"><a href=""><i class="fa fa-fw fa-search"></i></a></span> --->
								</th>
							{{/each}}
							<th>Actions:</th>
			  				<!--- <th>Name 
								{{#if columns.name.is_sorted}}
									{{#if columns.name.is_sorted_asc}}
										<span class="pull-right"><a href="{{columns.name.sort_desc_link}}"><i class="fa fa-fw fa-sort-desc"></i></a></span>
									{{else}}
										<span class="pull-right"><a href="{{columns.name.sort_asc_link}}"><i class="fa fa-fw fa-sort-asc"></i></a></span>
									{{/if}}
								{{else}}
									<span class="pull-right"><a href="{{columns.name.sort_asc_link}}"><i class="fa fa-fw fa-sort"></i></a></span>
								{{/if}}
			  				</th>
			  				<th>Category
								
			  				</th>
			  				<th>Price</th> --->
			  			</thead>

			  			<tbody>
			  				{{#each rows}}		  				
			  				<tr>		  					
								{{#each columns}}
									<td
									{{#if error_message}}
										{{#if ../error_message}}
											class="alert alert-danger"										
										{{/if}}
									{{/if}}
									>					
										{{#if error_message}}
											{{#if ../error_message}}
												<label class="label label-danger" style="display:block;">{{error_message}}</label>								
											{{/if}}
										{{/if}}


										<!--- {{#if @first}}
											<div style="margin-left:-75px; z-index:1; display:inline; position:absolute;">
											{{#if view_state.is_row_edit}}
												<button class="btn btn-primary">save</button>
											{{else}}
												<form action="{{base_path}}/list{{pagination.current_page.link}}" method="post" style="display:inline;">												
													<input type="hidden" name="edit_id" value="{{id}}">
													<button>edit</button>
												</form>	
											{{/if}}
											</div>
										{{/if}} --->
										{{#if column_type}}
											
											{{#if column_type.text}}
												{{#if editable}} <!--- if column is editable --->									
							  						{{#if edit}} <!--- if column is edit --->
							  							{{#if ../edit}} <!--- if row is edit --->

														

								  						<form id="data-grid-form-name{{../id}}" action="{{base_path}}/{{../id}}" method="post" class="form-inline" style="display:inline;" {{#if use_zero_ajax}}zero-target="#zero-grid"{{/if}}>
															<div class="form-group">
																<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
																<input type="hidden" name="goto_fail" value="{{pagination.current_page.link}}" />
																<input type="hidden" name="edit_col" value="{{column_name}}">
																<input type="hidden" name="edit_id" value="{{../id}}">
																<!--- <input type="hidden" name="preserve_request" value="true"> --->
																<input type="text" name="{{column_name}}" id="data-grid-input-name{{id}}" class="form-control input-sm" value="{{lookup ../this column_name}}" data-initial-value="{{lookup ../this column_name}}"/>
																<button class="btn btn-primary btn-xs">save</button>
																<a class="btn btn-default btn-xs" href="{{clear_edit_link}}">cancel</a>
															</div>
														</form>
														{{else}}
															<span id="data-grid-edit-name{{id}}" onClick="$('#data-grid-form-name{{id}}').show(); $(this).hide();">{{lookup ../this column_name}}</span>
														{{/if}}
													{{else}} <!--- Column not in edit --->

														<span id="data-grid-edit-name{{id}}" onClick="$('#data-grid-form-name{{id}}').show(); $(this).hide();">{{lookup ../this column_name}}</span>
														<span class="edit-link"><span>
															<form action="{{base_path}}/list" method="post" style="display:inline;" {{#if use_zero_ajax}}zero-target="#zero-grid"{{/if}}>
																{{#each current_params}}
																	<input type="hidden" name="{{name}}" value="{{value}}">
																{{/each}}		
																<input type="hidden" name="edit_col" value="{{column_name}}">
																<input type="hidden" name="edit_id" value="{{id}}">
																<button>edit</button>
															</form>								
														</span></span>
													{{/if}}								
												{{else}} <!--- NOT editable --->
													<span id="data-grid-edit-name{{id}}" onClick="$('#data-grid-form-name{{id}}').show(); $(this).hide();">{{lookup ../this column_name}}</span>
												{{/if}}
											{{/if}}

											{{#if column_type.checkbox}}
												<form id="data-grid-form-name{{../id}}" action="{{base_path}}/{{../id}}" method="post" class="form-inline" style="display:inline;" {{#if use_zero_ajax}}zero-target="#zero-grid"{{/if}}>
													<div class="form-group">
														<!--- {{../is_active}} --->
														<input type="hidden" name="goto" value="{{current_link}}" />
														<input type="hidden" name="is_active" value="{{#if ../is_active}}false{{else}}true{{/if}}">
														<!--- <input type="submit" name="{{column_name}}" id="data-grid-input-name{{id}}" class="form-control input-sm" value="{{lookup ../this column_name}}" data-initial-value="{{lookup ../this column_name}}" {{#if zero_is_checked}}checked{{/if}}/> --->
														<button id="data-grid-input-name{{id}}" class="form-control" style="border:none;" value="" data-initial-value="{{lookup ../this column_name}}">{{#if ../is_active}}&#9745;{{else}}&#9744;{{/if}}</button>													
													</div>
												</form>
											{{/if}}
											
											{{#if column_type.select}}
												{{#if edit}}
													{{#if ../edit}} <!--- If row is editable --->
													{{> zeroSelectForm}}
													<!--- <form id="data-grid-form-name{{../id}}" action="{{base_path}}/{{../id}}" method="post" class="form-inline" style="display:inline;">
														<div class="form-group">
															<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
															<select name="{{column_name}}" class="form-control">
																{{#each column_type.options}}
																	{{#select (lookup ../this column_name)}}<option value="{{id}}">{{name}}</option>{{/select}}
																{{/each}}
															</select>
															<button class="btn btn-primary btn-sm">save</button>
															<a class="btn btn-default btn-sm" href="{{pagination.current_page.link}}">cancel</a>												
														</div>
													</form> --->
													{{else}}
														<span id="data-grid-edit-name{{id}}" onClick="$('#data-grid-form-name{{id}}').show(); $(this).hide();">{{lookup ../this column_name}}</span>
														<span class="edit-link"><span>
															<form action="{{current_link}}" method="post" style="display:inline;">
																<input type="hidden" name="edit_col" value="{{column_name}}">
																<input type="hidden" name="edit_id" value="{{id}}">
																<button>edit</button>
															</form>								
														</span></span>
													{{/if}}
												{{else}}
													<span id="data-grid-edit-name{{id}}" onClick="$('#data-grid-form-name{{id}}').show(); $(this).hide();">{{lookup ../this column_name}}</span>
													<span class="edit-link"><span>
														<form action="{{current_link}}" method="post" style="display:inline;" {{#if use_zero_ajax}}zero-target="#zero-grid"{{/if}}>
															<input type="hidden" name="edit_col" value="{{column_name}}">
															<input type="hidden" name="edit_id" value="{{id}}">
															<button>edit</button>
														</form>								
													</span></span>
												{{/if}}
											{{/if}}
										{{else}}
											
										{{/if}}
				  					</td>
								{{/each}}
								<td>
			  						<form action="{{base_path}}/{{id}}/delete" method="post">
			  							<input type="hidden" name="goto" value="{{current_link}}" />
			  							<button>delete</button>
			  						</form>
			  					</td>
			  					<!--- <td>{{id}}</td>
			  					<td>
			  						{{#if edit}}
				  						<form id="data-grid-form-name{{id}}" action="{{base_path}}/{{id}}" method="post" class="form-inline" style="display:inline;">
											<div class="form-group">
												<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
												<input type="text" name="name" id="data-grid-input-name{{id}}" class="form-control input-sm" value="{{name}}" data-initial-value={{name}}/>
												<button class="btn btn-primary btn-xs">save</button>
												<a class="btn btn-default btn-xs" href="{{pagination.current_page.link}}">cancel</a>
											</div>
										</form>
									{{else}}
										<span id="data-grid-edit-name{{id}}" onClick="$('#data-grid-form-name{{id}}').show(); $(this).hide();">{{name}}</span>
									{{/if}}								
									<span class="edit-link"><span>
										<form action="{{base_path}}/list{{pagination.current_page.link}}" method="post" style="display:inline;">
											<input type="hidden" name="edit_col" value="">
											<input type="hidden" name="edit_id" value="{{id}}">
											<button>edit</button>
										</form>								
									</span></span>
			  					</td>
			  					<td>
			  						<form id="data-grid-form-category{{id}}" action="{{base_path}}/{{id}}" method="post" style="display:none;" class="form-inline">
										<div class="form-group">
											<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
											<input type="text" name="category" id="data-grid-input-category{{id}}" class="form-control input-sm" value="{{category}}" data-initial-value={{category}}/>
											<button class="btn btn-primary btn-xs">save</button>
											<a class="btn btn-default btn-xs" href="Javascript:$('#data-grid-input-category{{id}}').val($('#data-grid-input-category{{id}}').data('initial-value')); $('#data-grid-edit-category{{id}}').show(); $('#data-grid-form-category{{id}}').hide();">cancel</a>										
										</div>
									</form>
									<span id="data-grid-edit-category{{id}}" onClick="$('#data-grid-form-category{{id}}').show(); $(this).hide();">{{category}}</span>
			  					</td>
			  					<td>
			  						<form id="data-grid-form-price{{id}}" action="{{base_path}}/{{id}}" method="post" style="display:none;" class="form-inline">
										<div class="form-group">
											<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
											<input type="text" name="price" id="data-grid-input-price{{id}}" class="form-control input-sm" value="{{price}}" data-initial-value={{price}}/>
											<button class="btn btn-primary btn-xs">save</button>
											<a class="btn btn-default btn-xs" href="Javascript:$('#data-grid-input-price{{id}}').val($('#data-grid-input-price{{id}}').data('initial-value')); $('#data-grid-edit-price{{id}}').show(); $('#data-grid-form-price{{id}}').hide();">cancel</a>										
										</div>
									</form>
									<span id="data-grid-edit-price{{id}}" onClick="$('#data-grid-form-price{{id}}').show(); $(this).hide();">{{price}}</span>
			  					</td>
			  					<td>
			  						<form action="{{base_path}}/{{id}}/delete" method="post">
			  							<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
			  							<button>delete</button>
			  						</form>
			  					</td> --->
			  				</tr>
			  				
			  				{{/each}}
			  			</tbody>
					</table>
						
				</div>
			</div><!--- /row --->
			<div class="row">
				<div class="col-lg-6">
					Showing {{toString pagination.current_page.start_index}} to {{toString pagination.current_page.end_index}} of {{pagination.total_items}} entries					
				</div>			
				<div class="col-lg-6" style="">
					<nav aria-label="Page navigation" class="text-right">					
						<ul class="pagination text-right" style="margin-top:-5px;">						
							<li {{#if pagination.is_first_page}}class="disabled"{{/if}}>
								<a href="{{pagination.first_page.link}}" aria-label="Previous">
									<span aria-hidden="true">First</span>
								</a>
							</li>

							<li {{#unless pagination.has_previous_page}}class="disabled"{{/unless}}>
								<a href="{{pagination.previous_page.link}}" aria-label="Previous">
									<span aria-hidden="true">Previous</span>
								</a>
							</li>
							
							{{#each pagination.summary_pages}}							
								<li {{#if is_current_page}}class="active"{{/if}}><a href="{{link}}">{{toString id}}</a></li>							
							{{/each}}												
							<li {{#unless pagination.has_next_page}}class="disabled"{{/unless}}>
								<a href="{{pagination.next_page.link}}" aria-label="Next">
									<span aria-hidden="true">Next</span>
								</a>
							</li>

							<li {{#if pagination.is_last_page}}class="disabled"{{/if}}>
								<a href="{{pagination.last_page.link}}" aria-label="Previous">
									<span aria-hidden="true">Last</span>
								</a>
							</li>						
						</ul>
					</nav>

					
					<!--- <ul class="pagination pull-right">
						<li class="paginate_button previous disabled" aria-controls="dataTables-example" tabindex="0" id="dataTables-example_previous">
							<a href="#">Previous</a>
						</li>
						<li class="paginate_button active" aria-controls="dataTables-example" tabindex="0">
							<a href="#">1</a>
						</li>
						<li class="paginate_button " aria-controls="dataTables-example" tabindex="0">
							<a href="#">2</a>
						</li>
						<li class="paginate_button " aria-controls="dataTables-example" tabindex="0">
							<a href="#">3</a>
						</li>
						<li class="paginate_button " aria-controls="dataTables-example" tabindex="0">
							<a href="#">4</a>
						</li>
						<li class="paginate_button " aria-controls="dataTables-example" tabindex="0">
							<a href="#">5</a>
						</li>
						<li class="paginate_button " aria-controls="dataTables-example" tabindex="0">
							<a href="#">6</a>
						</li>
						<li class="paginate_button next" aria-controls="dataTables-example" tabindex="0" id="dataTables-example_next">
							<a href="#">Next</a>
							</li>
					</ul> --->	
				</div>
			</div>
		</div>
	</div>
</div>
</cf_handlebars>
<script type="text/javascript">

</script>