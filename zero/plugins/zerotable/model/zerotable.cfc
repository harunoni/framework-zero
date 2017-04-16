/**
 * The entry point for a zeroTable
 * @type {String}
 */
import _vendor.queryString.queryString;
component accessors="true" {

	property name="rows" setter="false";
	property name="columns" setter="false";
	property name="columnCount" setter="false";
	property name="primaryColumn" setter="false";
	property name="pagination" setter="false";
	property name="filters" setter="false";
	property name="max";
	property name="offset";
	property name="sort";
	property name="direction";
	property name="currentPageId";
	property name="search" setter="false";
	property name="showMoreLink" setter="false";
	property name="more" setter="false";
	property name="nextMore" setter="false";
	property name="currentLink" setter="false";
	property name="currentParams" setter="false";
	property name="currentParamsAsString" setter="false";
	property name="clearSearchLink" setter="false";
	property name="clearEditLink" setter="false";
	property name="basePath" setter="false";
	property name="useZeroAjax" setter="false";
	property name="ajaxTarget" setter="false";
	property name="persistFields" setter="false";
	property name="tableName" setter="false";
	property name="tableNamePrefix" setter="false";
	property name="rowEditPanelColumn" setter="false";
	property name="rowEditPanelId" setter="false";
	property name="rowEditPanelContent" setter="false";
	property name="style" type="struct" setter="false";
	property name="rowOnClick" type="any" setter="false";
	property name="hasFilterableColumns" setter="false";

	/**
	 * [init description]
	 * @param  {data}    required           Rows          		A component implementing the zerotable data interface
	 * @param  {Number}  required           max           		The maximum number of rows that the table should return
	 * @param  {Number}  required           offset        		The starting position in the source data to seek to
	 * @param  {Number}  					showMaxPages		The total number of pages to display in the summary section
	 * @param  {String}  string             basePath      		The base url path that query string paramters will be appended to
	 * @param  {Number}  numeric            more          		The number of additional items to show beyong the max
	 * @param  {Boolean} 					useZeroAjax         Whether to turn on ajax for the data table
	 * @param  {[type]}  					ajaxTarget          The HTML target attribute that zeroAjax will replace when the data table changes
	 * @param  {Object}  Required 			serializerIncludes 	When serializing over the entityDate output, this will tell zerotable to include nested data in the rows
	 * @return {zeroTable}                     					Returns an instance of zerotable
	 */
	public zeroTable function init(required data Rows,
						 required numeric max=10,
						 required numeric offset=0,
						 required showMaxPages=5,
						 required string basePath="",
						 required numeric more=0,
						 required useZeroAjax=true,
						 ajaxTarget,
						 required serializerIncludes={},
						 struct persistFields={},
						 tableName,
						 rowEditPanelColumn,
						 rowEditPanelContent,
						 style = {
						 	table:{
						 		striped:false,
						 		hover:true,
						 		bordered:true,
						 		condensed:false,
						 	}

						 }
						 ){

		variables.Rows = arguments.Rows;
		variables.max = arguments.max;
		variables.offset = arguments.offset;
		variables.columns = [];
		variables.showMaxPages = arguments.showMaxPages;
		variables.currentPageId = 1;
		variables.isSortedById = false;
		variables.basePath = arguments.basePath;
		variables.convertCamelCaseToUnderscore = false;
		variables.useZeroAjax = arguments.useZeroAjax;
		variables.serializerIncludes = arguments.serializerIncludes;
		variables.persistFields = arguments.persistFields;
		variables.siblingTables = [];
		variables.style = arguments.style;
		variables.hasFilterableColumns = false;

		if(arguments.keyExists("rowEditPanelColumn")){
			variables.hasRowEditPanel = true;
			variables.rowEditPanelColumn = arguments.rowEditPanelColumn;
		} else {
			variables.hasRowEditPanel = false;
		}

		if(arguments.keyExists("rowEditPanelContent")){
			variables.rowEditPanelContent = arguments.rowEditPanelContent;
		}

		if(arguments.keyExists("tableName")){
			variables.tableName = arguments.tableName;
		} else {
			variables.tableName = "";
		}

		if(arguments.keyExists("ajaxTarget")){
			variables.ajaxTarget = arguments.ajaxTarget;
		} else {
			variables.ajaxTarget = "##zero-grid#variables.tableName#";
		}
		// variables.searchString = "";
		variables.customColumns = [];


		if(arguments.keyExists("rowOnClick")){
			variables.rowOnClick = arguments.rowOnClick;
		}

		variables.qs = new queryString(cgi.query_string);
		variables.qs.delete(getFieldNameWithTablePrefix("search"))
					.delete(getFieldNameWithTablePrefix("sort"))
					.delete(getFieldNameWithTablePrefix("submit"))
					.delete(getFieldNameWithTablePrefix("max"))
					.delete(getFieldNameWithTablePrefix("offset"))
					.delete(getFieldNameWithTablePrefix("more"))
					//Not sure why jquery ajax is submitting an undefined variable, but delete it anyway
					.delete(getFieldNameWithTablePrefix("undefined"));

		setMore(arguments.more);
		setMax(arguments.max);
		setOffset(arguments.offset);

		//Set all of the persist fields into the query string
		for(var field in variables.persistFields){
			variables.qs.setValue(field, variables.persistFields[field]);
		}

		//Set the name for the table into the querystring if it exists
		if(variables.keyExists("tableName")){
			variables.qs.setValue(getFieldNameWithTablePrefix("table_name"), variables.tableName);
		}

		// variables.qs.setValues({
		// 	"max":variables.max,
		// 	"offset":variables.offset,
		// 	"more":variables.more
		// });

		variables.qs.setBasePath(arguments.basePath);

		if(variables.useZeroAjax){
			requiredAjaxFiles();
		}
		return this;
	}

	/*
	Adds additional persisted fields to the table that the table should include in
	its posts and gets. This is primarily used by other zerotables to pass
	themselves through so that each table on a page maintains its state
	 */
	public function addPersistFields(required struct fields){
		for(var field in arguments.fields){
			variables.persistFields.insert(field, arguments.fields[field], true);
			variables.qs.setValue(field, variables.persistFields[field], true);
		}
	}

	public function addColumn(required column column){
		var column = arguments.column;

		if(variables.convertCamelCaseToUnderscore){
			column.setColumnName(camelToUnderscore(column.getColumnName()));
		}

		var found = variables.columns.some(function(check){
			if(check.equals(column)){
				return true;
			} else {
				return false;
			}
		});
		if(!found){


			if(column.getIsPrimary()){
				variables.primaryColumn = new optional(Column);
			}

			variables.columns.append(column);
			column.setZeroTable(this);
			// column.setSortAscLink(variables.qs.getNew().setValues({"sort":column.getColumnName(), "direction":"asc"}).get());
			// column.setSortDescLink(variables.qs.getNew().setValues({"sort":column.getColumnName(), "direction":"desc"}).get());

		} else {
			throw("column already exists");
		}

		if(column.getFilterable()){
			variables.hasFilterableColumns = true;
		}
	}

	public function addSiblingTable(required zeroTable table){
		variables.siblingTables.append(arguments.table);
	}

	/**
	 * Breaks a camelCased string into separate words
	 * 8-mar-2010 added option to capitalize parsed words Brian Meloche brianmeloche@gmail.com
	 *
	 * @param str      String to use (Required)
	 * @param capitalize      Boolean to return capitalized words (Optional)
	 * @return Returns a string
	 * @author Richard (brianmeloche@gmail.comacdhirr@trilobiet.nl)
	 * @version 0, March 8, 2010
	 */
	function camelToUnderscore(str) {
	    var rtnStr=lcase(reReplace(arguments.str,"([A-Z])([a-z])","_\1\2","ALL"));
	    if (arrayLen(arguments) GT 1 AND arguments[2] EQ true) {
	        rtnStr=reReplace(arguments.str,"([a-z])([A-Z])","\1_\2","ALL");
	        rtnStr=uCase(left(rtnStr,1)) & right(rtnStr,len(rtnStr)-1);
	    }
		return trim(rtnStr);
	}

	private void function decorateRowsWithCustomColumns(required array rows){
		var columns = getCustomColumns();
		var rows = arguments.rows;
		for(var column in columns){
			var name = column.getColumnName();
			for(var row in rows){
				row[name] = column.getCustomOutput(row);
			}
		}
	}

	private void function decorateRowsWithWrapColumns(required array rows){
		var columns = getWrapColumns();
		var rows = arguments.rows;
		for(var column in columns){
			var name = column.getColumnName();
			for(var row in rows){
				row["wrap"][name] = column.getWrapOutput(row[name]);
			}
		}
	}

	private void function decorateRowsWithRowEditPanel(required array rows){
		var rows = arguments.rows;
		if(getHasRowEditPanel()){
			if(getHasRowEditPanelId()){
				for(var row in rows){
					if(row[getRowEditPanelColumn()] == getRowEditPanelId()){
						row["show_row_edit_panel"] = true;

						if(getHasRowEditPanelContent()){
							var rowEditPanelContent = getRowEditPanelContent();
							if(isClosure(rowEditPanelContent)){
								var out = rowEditPanelContent(row, this);
							} else {
								var out = rowEditPanelContent;
							}
							row["row_edit_panel_content"] = out;
						}
					}
				}
			}
		}
	}

	private void function decorateRowsWithRowOnClick(required array rows){
		var rows = arguments.rows;
		if(getHasRowOnClick()){

			for(var row in rows){
				if(isClosure(getRowOnClick())){
					var onClick = getRowOnClick();
					row["row_on_click"] = evaluate('onClick(row)');
				} else {
					row["row_on_click"] = getRowOnClick();
				}
			}
		}
	}

	public function edit(required string columnName, required string rowId, string errorMessage){


		var column = findColumnByName(arguments.columnName).elseThrow("Could not find the column #columnName#");
		column.setEdit(true);

		if(arguments.keyExists("errorMessage")){
			column.setErrorMessage(arguments.errorMessage);
		}

		var primaryColumn = getPrimaryColumn().elseThrow("Can only edit tables which have a primary column. Add a primary column");
		variables.qs.setValues({"#getFieldNameWithTablePrefix("edit_col")#":primaryColumn.getColumnName(), "edit_id":rowId});
		for(var row in getRows()){
			var name = primaryColumn.getColumnName();
			if(row[name] == arguments.rowId){
				row.edit = true;

				if(arguments.keyExists("errorMessage")){
					row.error_message = arguments.errorMessage;
				}

			} else {
				row.edit = false;
			}
		}
	}

	/*
	Takes a column to filter, updates the column class and updates
	the data class to perform the filtering
	 */
	public function filter(required string columnName, required any value){
		var column = findColumnByName(arguments.columnName).elseThrow("Could not find the column #arguments.columnName#");
		column.setFilteredValue(arguments.value);
		variables.rows.filter(column.getDataName(), arguments.value);
	}

	public Optional function findColumnByName(required string columnName){
		var columnName = arguments.columnName;
		var found = variables.columns.find(function(column){
			if(lcase(column.getColumnName()) == columnName){
				return true;
			} else {
				return false;
			}
		});
		if(!found){
			return new optional();
		} else {
			return new optional(getColumns()[found]);
		}
	}

	public string function getClearEditLink(){
		return variables.qs.getNew().delete(getFieldNameWithTablePrefix("edit_col")).delete(getFieldNameWithTablePrefix("edit_id")).get();
	}

	public string function getClearSearchLink(){
		// writeDump(variables.qs.get());
		return variables.qs.getNew().setBasePath("#variables.basePath#")
									.delete(getFieldNameWithTablePrefix("search"))
									.delete(getFieldNameWithTablePrefix("edit_col"))
									.delete(getFieldNameWithTablePrefix("edit_id")).get();
	}

	public string function getCurrentLink(){
		return variables.qs.getNew().setBasePath("#variables.basePath#").get();
	}

	public function getFieldNameWithTablePrefix(required string field){
		if(variables.keyExists("tableName") and variables.tableName != ""){
			return "#variables.tableName#.#arguments.field#";
		} else {
			return arguments.field;
		}
	}

	public function getColumnCount(){
		return arrayLen(variables.columns);
	}

	public column[] function getCustomColumns(){
		var out = [];
		for(var column in variables.columns){
			if(column.getColumnType().keyExists("custom")){
				out.append(column);
			}
		}
		return out;
	}

	public function getHasFilters(){
		return variables.keyExists("filters") and !variables.filters.isEmpty();
	}

	public function getHasRowEditPanel(){
		return variables.hasRowEditPanel;
	}

	public boolean function getHasRowEditPanelId(){
		return variables.keyExists("rowEditPanelId");
	}

	public boolean function getHasRowEditPanelContent(){
		return variables.keyExists("rowEditPanelContent");
	}

	public boolean function getHasRowOnClick(){
		return variables.keyExists("rowOnClick");
	}

	public string function getShowMoreLink(){

		return variables.qs.getNew().setValues({"#getFieldNameWithTablePrefix("offset")#":variables.offset, "#getFieldNameWithTablePrefix("max")#": max+max}).get();

	}

	public column[] function getWrapColumns(){
		var out = [];
		for(var column in variables.columns){
			if(column.getHasWrap()){
				out.append(column);
			}
		}
		return out;
	}

	public pagination function getPagination(){

		return new pagination(data=variables.Rows,
							  max=variables.max + variables.more,
							  offset=variables.offset,
							  showMaxPages=variables.showMaxPages,
							  zeroTable=this);
	}

	public array function getPrimaryParams(){
		var params = ["offset", "max", "search", "sort", "direction", "more"];
		var out = [];
		for(var param in params){


			var value = evaluate("this.get#param#()");

			if(isNull(value)){
				//Do nothing with the paramter
				// writeDump(param);
				// abort;
			} else {

				if(isInstanceOf(value,"optional")){
					if(!value.exists()){
						continue;
					}
				}

				if(!isNull(value)){
					out.append({
						"name":getFieldNameWithTablePrefix(param),
						"value":evaluate("this.get#param#()"),
						"is_#param#":true
					});
				}
			}
		}

		if(getHasFilters()){

			var filters = getFilters();
			for(var filter in filters){

				var data = {
					"name":"filters.#filter#",
					"value":filters[filter],
					"is_filter":true,
					"column":{
						"#filter#":true
					}
				}
				out.append(data);
			}
		}
		// writeDump(out);
		// abort;

		if(getHasRowEditPanel()){
			if(getHasRowEditPanelId()){
				out.append({
					"name":getFieldNameWithTablePrefix("row_edit_panel"),
					"value":getRowEditPanelId(),
					"is_row_edit_panel":true
				})
			}
		}

		//Add a table name if it exists to the out, this allows the user
		//to support multiple zerotables
		if(variables.keyExists("tableName")){
			out.append({
				"name":getFieldNameWithTablePrefix("table_name"),
				"value":variables.tableName,
				"is_table_name":true,
				"is_#variables.tableName#":true
			})
		}

		return out;
	}

	public struct function getPrimaryParamsAsStruct(){
		var params = getPrimaryParams();
		var out = {};
		for(var param in params){
			out.insert(param.name, param, true);
		}
		return out;
	}

	public struct function getPrimaryParamsAsKeyValue(){

		var params = getPrimaryParamsAsStruct();
		var paramsOut = {};
		for(var param in params){

			if(isInstanceOf(params[param].value, "optional")){
				if(params[param].value.exists()){
					paramsOut.insert(param, params[param].value.get(), true);
				}
			} else {
				paramsOut.insert(param, params[param].value, true);
			}
		}
		return paramsOut;
	}

	public array function getCurrentParams(){

		var out = getPrimaryParams();

		//Add the persistFields to the currentParams out
		for(var key in persistFields){
			out.append({
				"name":key,
				"value":persistFields[key],
				"is_#key#":true
			});
		}

		return out;
	}

	public struct function getCurrentParamsAsStruct(){
		var params = getCurrentParams();
		var out = {};
		for(var param in params){
			out.insert(param.name, param, true);
		}
		return out;
	}

	public struct function getCurrentParamsAsKeyValue(){

		var params = getCurrentParamsAsStruct();
		var paramsOut = {};
		for(var param in params){

			if(isInstanceOf(params[param].value, "optional")){
				if(params[param].value.exists()){
					paramsOut.insert(param, params[param].value.get(), true);
				}
			} else {
				paramsOut.insert(param, params[param].value, true);
			}
		}
		return paramsOut;
	}

	public string function getCurrentParamsAsString(){
		return variables.qs.getNew().setBasePath("").get();
	}

	public queryString function getCurrentParamsAsQueryString(){
		return variables.qs.getNew();
	}

	public optional function getPrimaryColumn(){
		return variables.primaryColumn?: new optional();
	}

	public queryString function getQueryString(){
		return variables.qs;
	}

	public function getRows(){

		if(!variables.isSortedById){
			var primaryColumn = getPrimaryColumn();
			if(primaryColumn.exists()){
				variables.Rows.sort(primaryColumn.get().getDataName(), "asc");
			}
		}

		if(isNull(variables.serializedRows)){
			var rows = variables.Rows.list(max=variables.max + variables.more, offset=variables.offset);
			var rows = new serializer().serializeEntity(rows, variables.serializerIncludes);
			variables.serializedRows = rows;
		}
		return variables.serializedRows;
	}

	public Optional function getsearch(){
		if(isNull(variables.searchString)){
			return new Optional();
		} else {
			return new Optional(variables.searchString);
		}
	}

	public function getSort(){
		// if(isNull(variables.sortString)){
		// 	return new Optional();
		// } else {
		// 	return new Optional(variables.sortString);
		// }
		return variables.sortString?:"";
	}

	private function requiredAjaxFiles(){
		include template="/zero/plugins/zerotable/model/require_js.cfm";
	}

	public void function pageTo(required numeric id){
		variables.currentPageId = arguments.id;
	}

	public void function persistSiblingTable(required zeroTable table){

		addPersistFields(arguments.table.getPrimaryParamsAsKeyValue());
		arguments.table.addPersistFields(this.getPrimaryParamsAsKeyValue());
		// this.addSiblingTable(arguments.table);
		// arguments.table.addSiblingTable(this);
	}

	public void function search(required string search){
		variables.searchString = arguments.search;
		variables.qs.setValues({"#getFieldNameWithTablePrefix("search")#":variables.searchString});
		variables.Rows.search(arguments.search);

		if(variables.rows.count() <= variables.offset){
			// variables.offset = variables.offset - variables.max;
			variables.offset = 1;
		}
	}

	private function setMore(required numeric more){
		variables.more = arguments.more;
		variables.nextMore = variables.more + variables.max;
		variables.qs.setValue(getFieldNameWithTablePrefix("more"), arguments.more);
	}

	private function setMax(required numeric max){
		variables.max = arguments.max;
		variables.qs.setValue(getFieldNameWithTablePrefix("max"), arguments.max);
	}

	private function setOffset(required numeric offset){
		variables.offset = arguments.offset;
		variables.qs.setValue(getFieldNameWithTablePrefix("offset"), arguments.offset);
	}

	public void function sort(required string column, required string direction){

		var column = findColumnByName(arguments.column).elseThrow("The column name #arguments.column# was not a valid name");

		variables.Rows.sort(column=column.getDataName(), direction=arguments.direction);

		if(column.getIsPrimary()){
			variables.isSortedById = true;
		}

		variables.sortString = column.getColumnName();
		variables.direction = arguments.direction;

		variables.qs.setValues({"#getFieldNameWithTablePrefix("sort")#":column.getColumnName(), "#getFieldNameWithTablePrefix("direction")#":arguments.direction});

		// for(var updateColumn in variables.columns){
		// 	updateColumn.setQueryString(variables.qs.getNew());
		// }

		column.setIsSorted(true);
		if(direction == "asc"){
			column.setIsSortedAsc(true);
		} else {
			column.setIsSortedDesc(true);
		}

	};

	public struct function toJson(){

		var pagination = this.getPagination();
		var paginationOut = pagination.toJson();
		var pagination = this.getPagination();

		var zeroOut = {};
		zeroTableOut["max"] = this.getmax();
		zeroTableOut["offset"] = this.getoffset();
		zeroTableOut["sort"] = this.getSort();
		zeroTableOut["direction"] = this.getdirection();
		zeroTableOut["current_page_id"] = this.getcurrentPageId();
		zeroTableOut["column_count"] = this.getColumnCount();
		zeroTableOut["has_filterable_columns"] = this.getHasFilterableColumns();
		zeroTableOut["has_filters"] = this.getHasFilters();
		zeroTableOut["search"] = this.getsearch().else("");
		zeroTableOut["show_more_link"] = this.getshowMoreLink();
		zeroTableOut["more"] = this.getmore();
		zeroTableOut["next_more"] = this.getnextMore();
		zeroTableOut["current_link"] = this.getcurrentLink();
		zeroTableOut["current_params_as_string"] = this.getcurrentParamsAsString();
		zeroTableOut["clear_search_link"] = this.getclearSearchLink();
		zeroTableOut["clear_edit_link"] = this.getclearEditLink();
		zeroTableOut["base_path"] = this.getbasePath();
		zeroTableOut["use_zero_ajax"] = this.getuseZeroAjax();
		zeroTableOut["ajax_target"] = this.getAjaxTarget();
		zeroTableOut["persist_fields"] = this.getPersistFields();
		zeroTableOut["style"] = new serializer().serializeEntity(this.getStyle());

		if(variables.keyExists("tableName")){
			zeroTableOut["table_name"] = variables.tableName;
			zeroTableOut["table_name_prefix"] = "#variables.tableName#."
		} else {
			zeroTableOut["table_name_prefix"] = "";
		}

		zeroTableOut["rows"] = new serializer().serializeEntity(this.getRows());
		zeroTableOut["pagination"] = this.getPagination().toJson();
		zeroTableOut["columns"] = [];
		for(var column in this.getColumns()){
			zeroTableOut["columns"].append(column.toJson())
		}

		zeroTableOut["primary_column"] = this.getPrimaryColumn().get().toJson();
		zeroTableOut["current_params"] = this.getCurrentParams();

		for(var param in zeroTableOut["current_params"]){
			if(isInstanceOf(param.value, "optional")){
				param.value = param.value.else("");
			}
		}

		// for(var siblingTable in variables.siblingTables){
		// 	var siblingParams = siblingTable.getCurrentParams();
		// 	arrayMerge(zeroTableOut["current_params"], siblingParams);
		// }

		decorateRowsWithCustomColumns(zeroTableOut.rows);
		decorateRowsWithWrapColumns(zeroTableOut.rows);
		decorateRowsWithRowEditPanel(zeroTableOut.rows);
		decorateRowsWithRowOnClick(zeroTableOut.rows);

		return zeroTableOut;
	}

	public function update( numeric max=10,
							numeric more,
							numeric offset=1,
							sort,
							direction,
							goto_page,
							search,
							edit_col,
							edit_id,
							row_edit_panel,
							edit_message,
							filters){

		// writeDump(arguments);
		// writeDump(callStackGet());
		if(arguments.keyExists("max") and trim(arguments.max) != ""){ setMax(arguments.max)}
		if(arguments.keyExists("more") and trim(arguments.more) != "" and more > 0){ setMore(arguments.more)}
		if(arguments.keyExists("offset") and trim(arguments.offset) != ""){ setOffset(arguments.offset)}

		//SORTING
		if(arguments.keyExists("sort") and trim(arguments.sort) != ""){
			var dir = "asc";
			if(arguments.keyExists("direction") and trim(arguments.direction) != ""){dir = arguments.direction}
			this.sort(arguments.sort, dir);
		}

		//FILTERING
		if(arguments.keyExists("filters")){
			variables.filters = arguments.filters;
			for(var filter in filters){
				this.filter(columnName=filter, value=filters[filter]);
			}
		}


		//SEARCHING
		if(arguments.keyExists("search") and trim(arguments.search) != ""){
			this.search(arguments.search);
		}

		//EDITING
		if(
			(arguments.keyExists("edit_col") and trim(arguments.edit_col) != "") and
			(arguments.keyExists("edit_id") and trim(arguments.edit_id) != "")
		){

			if(arguments.keyExists("edit_message") and trim(arguments.edit_message) != ""){
				this.edit(arguments.edit_col, arguments.edit_id, arguments.edit_message);
			} else {
				this.edit(arguments.edit_col, arguments.edit_id);
			}
		}

		if(arguments.keyExists("row_edit_panel") and trim(arguments.row_edit_panel) != ""){
			variables.rowEditPanelId = arguments.row_edit_panel;
		}

		//JUMP TO PAGE. Needs to be last so that other values are updated first
		if(arguments.keyExists("goto_page") and trim(arguments.goto_page) != ""){
			var pagination = getPagination();
			var page = pagination.findPageById(arguments.goto_page).elseThrow("That is not a valid page to go to");
			location url="#page.getLink()#" addtoken="false";
		}

	}

	public function updateWithZeroTableFields(zeroTableFields zeroTableFields){
		update(argumentCollection=arguments.zeroTableFields.toStruct());
	}


}