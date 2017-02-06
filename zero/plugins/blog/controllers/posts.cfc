component accessors="true" {    
	
	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	public struct function new( rc ) {
    	return {};
	}
	
	public struct function list( ) {
		var blog = variables.fw.getBlog();
		var out = {
			"success":true,
			"data":variables.fw.serialize(blog, {
				articles:{
					author:{},
					tags:{}}, 
					tags:{
						articles:{}
				},
				authors:{}
			})
		}
		// writeDump(out);
		// abort;
    	return out; 
	}

	public struct function create( rc ) {
    	return {};
	}

	public struct function read( rc ) {
		var blog = variables.fw.getBlog();

		path = cgi.path_info & ".cfm";
		path = right(path, len(path) - 1);

		//Setup blog framework variables
		// template = getTemplateFromPath(path);
		template = cgi.path_info;
		request.template = listLast(template,"/");
		request.title = request.template.replaceNoCase("-", " ", "all");

		var article = blog.findArticle(title=request.title);

		var out = {
			"success":true,
			"data":variables.fw.serialize(article, {
				author:{},
				tags:{}
			})
		}
		// writeDump(out);
    	return out;
	}

	public struct function update( rc ) {
    	return {};
	}

	public struct function delete( rc ) {
    	return {};
	}

	// public struct function onMissingMethod( ){
	// 	writeDump(request.context.action);			
	// 	var item = variables.fw.getItem();
	// 	request.includePath = item & ".cfm";
	// 	variables.fw.setView('home:pages.list');
	// 	return {}
	// }
	
}
