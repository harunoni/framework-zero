<cfscript>
// rc.data["use_zero_ajax"] = false;
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

<cfset zeroTableContext = request.zeroTableContext?:rc.data>
<cf_handlebars context="#zeroTableContext#">
<div class="row" id="zero-grid">
	<div class="col-lg-12">
		<div class="row" style="margin-bottom:10px;">
			<div class="col-lg-12">

			</div>
		</div>
		<div class="row" style="margin-bottom:10px;">
			<div class="col-lg-8">
				<form id="max_items{{table_name}}" action="{{base_path}}" method="get" class="form-inline" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>
					{{#each current_params}}
						{{#unless is_max}}
							{{#unless is_more}}
							<input type="hidden" name="{{name}}" value="{{value}}">
							{{/unless}}
						{{/unless}}
					{{/each}}
					<div class="form-group">
						<label>Show </label>
						<select class="form-control" name="{{table_name_prefix}}max" onChange="$('#max_items{{table_name}}').submit();">
							{{#select max}}<option value="10">10</option>{{/select}}
							{{#select max}}<option value="25">25</option>{{/select}}
							{{#select max}}<option value="50">50</option>{{/select}}
							{{#select max}}<option value="100">100</option>{{/select}}
							{{#select max}}<option value="200">200</option>{{/select}}
							{{#select max}}<option value="All">All</option>{{/select}}
						</select>
						<label>records</label>
					</div>
					<button id="max_select_button" class="btn btn-primary">Go</button>
				</form>
			</div>
			<div class="col-lg-4 text-right">
				<div class="form-group" class="pull-right" style="display:inline;">
					<form id="search-form" method="GET" action="{{base_path}}" class="form-inline" style="display:inline;" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>
						{{#each current_params}}
							{{#unless is_search}}
								<input type="hidden" name="{{name}}" value="{{value}}">
							{{/unless}}
						{{/each}}
						<input name="{{table_name_prefix}}search" type="text" class="form-control input-sm" value="{{search}}">
						<button name="submit" value="search" class="btn btn-primary btn-sm">Search</button>
					</form>
					{{#if use_zero_ajax}}
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

										if(newKey !== 'undefined' && newKey !== 'Backspace'){
											searchInput.attr('value', prior + newKey);
										}

										var strLength = searchInput.val().length * 2;
										searchInput.focus();
										searchInput[0].setSelectionRange(strLength, strLength);

										event.preventDefault();
										searchForm.submit();

									}, 1000);
									isTimeout = false;
								}

							});
						</script>
					{{/if}}
					{{#if search}}
						<script>
							var searchInput = $('#search-form > input[name="search"]');
							searchInput.focus();
							var strLength = searchInput.val().length * 2;
							searchInput.focus();
							searchInput[0].setSelectionRange(strLength, strLength);
						</script>
					{{/if}}
					<a class="btn btn-default btn-sm" href="{{clear_search_link}}" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>Clear</a>
				</div>
			</div>
		</div>
		<div>
			<div class="row">
				<div class="col-lg-12">

					<div class="table-responsive">
					<table id="zerotable" class="table table-bordered" >
			  			<thead>
							{{#each columns}}
								<th>{{friendly_name}}
									{{#if is_sorted}}
										{{#if is_sorted_asc}}
											<span class="pull-right"><a href="{{sort_desc_link}}" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}><i class="fa fa-fw fa-sort-desc"></i></a></span>
										{{else}}
											<span class="pull-right"><a href="{{sort_asc_link}}" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}><i class="fa fa-fw fa-sort-asc"></i></a></span>
										{{/if}}
									{{else}}
										<span class="pull-right"><a href="{{sort_asc_link}}" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}><i class="fa fa-fw fa-sort"></i></a></span>
									{{/if}}
										<!--- <span class="pull-right"><a href=""><i class="fa fa-fw fa-filter"></i></a></span>
										<span class="pull-right"><a href=""><i class="fa fa-fw fa-search"></i></a></span> --->
								</th>
							{{/each}}
			  			</thead>

			  			<tbody>
			  				{{#each rows}}
			  				<tr>
								{{#each columns}}
									<td id="cell-{{column_name}}-{{id}}"
									style="vertical-align: middle; padding:0px; height:1px;"
									>
										<div
											style="margin:0px; border-radius:0px; border:none; height:100%; width:100%; display:table;"
											class="cell-wrapper-{{column_name}}-{{id}}
												{{#if error_message}}
													{{#if ../error_message}}
														alert alert-danger
													{{/if}}
												{{/if}}
											"
										>
										{{#if error_message}}
											{{#if ../error_message}}
												<label class="label label-danger" style="display:block;">{{error_message}}</label>
											{{/if}}
										{{/if}}

										{{#if column_type}}
											{{#if column_type.text}}
												{{#if editable}} <!--- if column is editable --->

													<!--- TEXT EDIT WEB COMPONENT

													This web component is made up of a text edit box with a save/cancel button
													and an enable edit button, which is the text of the column

													Notes:
													- In order to have a hitbox which takes up the entire width and height
													  of the cell, we emply a few strategies:

													  1. The td side is 1px, which will force it to be the side of any child elements
													  2. Each form input and edit button are 100% width and height
													  3. Using a padding trick to get vertical alignment out of the form elements: http://vanseodesign.com/css/vertical-centering/
													  4. Inside the TD is a div.table and div.tabel-cell, this is so that we can vertically-align regular text
													  5. Visibility is controlled by a ID+Class selector. By default the input form is hidden, and is made visible by adding a visiblity class

													--->
													<style>
														#data-grid-form-{{column_name}}-{{../id}} {
															display:none;
														}

														.hidden-{{column_name}}-{{id}} {
															display:none;
														}

														#data-grid-form-{{column_name}}-{{../id}}.visible-{{column_name}}-{{id}} {
															display:block;
														}

														button.link {
														     background:none!important;
														     border:none;
														     padding:0!important;
														     font: inherit;
														     /*border is optional*/
														     border-bottom:1px solid #444;
														     cursor: pointer;
														}

														button.text {
														     background:none!important;
														     border:none;
														     padding:0!important;
														     font: inherit;
														     /*border is optional*/
														     border-bottom:none;
														     cursor: pointer;
														}
													</style>

													<!--- EDIT FIELD --->
													<form id="data-grid-form-{{column_name}}-{{../id}}"
														  action="{{base_path}}/{{../id}}"
														  method="post"
														  style="margin:0px; padding:1% 0; height:100%; padding-left:5px;"
														  class="text-edit
														  		 form-inline
														  		 {{#if edit}}
														  		 	{{#if ../edit}}
														  		 		visible-{{column_name}}-{{id}}
														  		 	{{/if}}
														  		 {{/if}}"
														 {{#if use_zero_ajax}}zero-target="#cell-{{column_name}}-{{id}}"{{/if}}>

														<div class="" style="padding:2% 0; width:100%">
															<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
															<input type="hidden" name="goto_fail" value="{{pagination.current_page.link}}" />
															<input type="hidden" name="edit_col" value="{{column_name}}">
															<input type="hidden" name="edit_id" value="{{../id}}">
															<!--- <input type="hidden" name="preserve_request" value="true"> --->
															<input type="text"
																   name="{{column_name}}"
																   id="data-grid-input-name{{id}}"
																   class="form-control input-sm"
																   style="width:60%; height:32px;"
																   value="{{lookup ../this column_name}}"
																   data-initial-value="{{lookup ../this column_name}}"/>

															<button class="btn btn-primary btn-sm" style="">save</button>
															<button name="submit_overload"
																	value="{'clear_form':true}"
																	formaction="{{pagination.current_page.link}}"
																	class="btn btn-default btn-sm cancel-button"
																	style="
																href="{{clear_edit_link}}"
																onClick="$('#data-grid-form-{{column_name}}-{{../id}}').hide(); $('#enable-edit-{{column_name}}-{{id}}').show(); return false;"
																>cancel</button>
														</div>
													</form>

													<div style="display:table-cell; position:relative">
														<!--- ENABLE EDIT FIELD --->
														<form id="enable-edit-{{column_name}}-{{id}}"
															  action="{{base_path}}"
															  method="post"
															  style="margin:0px; padding:0px; height:100%"
															  {{#if use_zero_ajax}}zero-target="#cell-{{column_name}}-{{id}}"{{/if}}
															  class="
															  		text-enable-edit
																{{#if edit}}
														  		 	{{#if ../edit}}
														  		 		hidden-{{column_name}}-{{id}}
														  		 	{{/if}}
														  		 {{/if}}"
															  "
															  >
															{{#each current_params}}
																<input type="hidden" name="{{name}}" value="{{value}}">
															{{/each}}
															<input type="hidden" name="edit_col" value="{{column_name}}">
															<input type="hidden" name="edit_id" value="{{id}}">
															<button class="text"
																	style="display:block; text-align:left; width:100%; height:100%; position:absolute;"
																	onClick="$('#data-grid-form-{{column_name}}-{{../id}}').show(); $('#enable-edit-{{column_name}}-{{id}}').hide(); return false;"
																	>
																	<span style="padding-left:5px;">
																		{{#if (lookup ../this.wrap column_name)}}
																			{{{lookup ../this.wrap column_name}}}
																		{{else}}
																			{{lookup ../this column_name}}
																		{{/if}}
																	</span>
															</button>
														</form>
													</div>


												{{else}} <!--- NOT editable --->
													<div style="display:table-cell; vertical-align:middle;">
														{{#if (lookup ../this.wrap column_name)}}
															<span id="data-grid-edit-name{{id}}" style="padding-left:5px;">{{{lookup ../this.wrap column_name}}}</span>
														{{else}}
															<span id="data-grid-edit-name{{id}}" style="padding-left:5px;">{{lookup ../this column_name}}</span>
														{{/if}}
													</div>
												{{/if}}
											{{/if}}

											{{#if column_type.custom}}
												<div style="display:table-cell; vertical-align:middle; padding-left:5px;">
													{{{lookup ../this column_name}}}
												</div>
												<!--- {{{lookup ../this column_name}}} --->
											{{/if}}

											{{#if column_type.checkbox}}
												<form id="data-grid-form-name{{../id}}" action="{{base_path}}/{{../id}}" method="post" class="form-inline" style="display:inline;" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>
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
												<style>
													#data-grid-form-name-{{column_name}}-{{../id}} {
														display:none;
													}

													.hidden-{{column_name}}-{{id}} {
														display:none;
													}

													#data-grid-form-name-{{column_name}}-{{../id}}.visible-{{column_name}}-{{id}} {
														display:block;
													}

													button.link {
													     background:none!important;
													     border:none;
													     padding:0!important;
													     font: inherit;
													     /*border is optional*/
													     border-bottom:1px solid #444;
													     cursor: pointer;
													}

													button.text {
													     background:none!important;
													     border:none;
													     padding:0!important;
													     font: inherit;
													     /*border is optional*/
													     border-bottom:none;
													     cursor: pointer;
													}
												</style>

												<form id="data-grid-form-name-{{column_name}}-{{../id}}"
													  action="{{base_path}}/{{../id}}"
													  method="post"
													  class="form-inline
															{{#if edit}}
																{{#if ../edit}}
																	visible-{{column_name}}-{{id}}
																{{/if}}
															{{/if}}

													  "
													  style="padding:1% 0; padding-left:5px;"
													  {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>

													<div class="form-group" style="padding:2% 0;">
														<input type="hidden" name="goto" value="{{pagination.current_page.link}}" />
														<select name="{{column_name}}" class="form-control" style="">
															{{#each column_type.options}}
																{{#select (lookup ../this column_name)}}<option value="{{id}}">{{name}}</option>{{/select}}
															{{/each}}
														</select>
														{{#unless hide_buttons}}
														<button class="btn btn-primary btn-sm">save</button>
														<a class="btn btn-default btn-sm" href="{{clear_edit_link}}">cancel</a>
														{{/unless}}
													</div>
												</form>

												<!--- ENABLE EDIT FIELD --->
												<div style="display:table-cell; position:relative;">

													<form id="enable-edit-{{column_name}}-{{id}}"
														  action="{{base_path}}"
														  method="post"
														  style="margin:0px; padding:0px; height:100%"
														  {{#if use_zero_ajax}}zero-target="#cell-{{column_name}}-{{id}}"{{/if}}
														  class="
														  		text-enable-edit
															{{#if edit}}
													  		 	{{#if ../edit}}
													  		 		hidden-{{column_name}}-{{id}}
													  		 	{{/if}}
													  		 {{/if}}"
														  "
														  >
														{{#each current_params}}
															<input type="hidden" name="{{name}}" value="{{value}}">
														{{/each}}
														<input type="hidden" name="edit_col" value="{{column_name}}">
														<input type="hidden" name="edit_id" value="{{id}}">
														<button class="text"
																style="display:block; text-align:left; width:100%; height:100%; position:absolute;"
																<!--- onClick="$('#data-grid-form-name{{../id}}').show(); $('#enable-edit-{{column_name}}-{{id}}').hide(); return false;" --->
																>
																<span style="padding-left:5px;">
																	{{#if (lookup ../this.wrap column_name)}}
																		{{{lookup ../this.wrap column_name}}}
																	{{else}}
																		{{lookup ../this column_name}}
																	{{/if}}
																</span>
														</button>
													</form>
												</div>
											{{/if}}
										{{else}}

										{{/if}}
										</div>
				  					</td>
								{{/each}}
			  				</tr>

			  				{{/each}}
			  			</tbody>
					</table>
					</div>
				</div>
			</div><!--- /row --->
			<div class="row">
				<div class="col-lg-3">
					Showing {{toString pagination.current_page.start_index}} to {{toString pagination.current_page.end_index}} of {{pagination.total_items}} entries
				</div>
				<div class="col-lg-2">
					<form action="{{base_path}}" method="GET" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>
						<!--- Loop through and output all variables except more,
						because more gets calculated to add the number offset every
						time more is called --->
						{{#each current_params}}
							{{#unless is_more}}
								<input type="hidden" name="{{name}}" value="{{value}}">
							{{/unless}}
						{{/each}}
						<input type="hidden" name="{{table_name_prefix}}more" value="{{next_more}}">
						<button class="btn btn-sm">Show {{toString max}} more</button>
					</form>
				</div>
				<div class="col-lg-7" style="">
					<div class="row">
						<div class="col-lg-12">
							<nav aria-label="Page navigation" class="text-right">
								<ul class="pagination text-right" style="margin-top:-5px;">
									<li {{#if pagination.is_first_page}}class="disabled"{{/if}}>
										<a href="{{pagination.first_page.link}}" aria-label="Previous" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>
											<span aria-hidden="true">First</span>
										</a>
									</li>

									<li {{#unless pagination.has_previous_page}}class="disabled"{{/unless}}>
										<a href="{{pagination.previous_page.link}}" aria-label="Previous" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>
											Previous
										</a>
									</li>

									{{#each pagination.summary_pages}}
										<li {{#if is_current_page}}class="active"{{/if}}><a href="{{link}}" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>{{toString id}}</a></li>
									{{/each}}
									<li {{#unless pagination.has_next_page}}class="disabled"{{/unless}}>
										<a href="{{pagination.next_page.link}}" aria-label="Next" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>Next</a>
									</li>

									<li {{#if pagination.is_last_page}}class="disabled"{{/if}}>
										<a href="{{pagination.last_page.link}}" aria-label="Previous" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>
											<span aria-hidden="true">Last</span>
										</a>
									</li>

									<li class="" style="margin-left:15px;">
										<form action="{{base_path}}" method="POST" class="form-inline" style="display:inline;" {{#if use_zero_ajax}}zero-target="{{ajax_target}}"{{/if}}>
											<div class="form-group">

												{{#each current_params}}
													{{#unless is_goto_page}}
														<input type="hidden" name="{{name}}" value="{{value}}">
													{{/unless}}
												{{/each}}
												<button class="form-control btn-primary btn btn-sm">go to page</button>
												<input name="{{table_name_prefix}}goto_page" class="form-control" type="page" style="width:50px;">
												of {{toString pagination.total_pages}} pages
											</div>
										</form>
									</li>
								</ul>
							</nav>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

{{#if use_zero_ajax}}
	<script>
	NProgress.configure({ parent: "#zerotable", showSpinner: false });
	$( document ).ajaxStart(function() {
		NProgress.start();
	  // $( "#loading" ).show();
	}).ajaxStop(function() {
		NProgress.done();
	  // $( "#loading" ).hide();
	});
	</script>
{{/if}}
</cf_handlebars>