component accessors="true" {    
	
	public any function init( fw ) {
		variables.fw = fw;
		writeDump(request.action);
		return this;
	}

	public struct function new( rc ) {
    	return {};
	}
	
	public struct function list( ) {
    	return {}; 
	}

	public struct function create( rc ) {
    	return {};
	}

	public struct function read( id ) {
		var blog = variables.fw.getBlog();
		var articles = blog.findArticlesByTag(id);

		var tags = [];
		articles.each(function(article){			
			article.getTags().each(function(tag){
				tags.append(tag);
			});
		});


		tags = blog.distinct(tags);

		// writeDump(tags);

		var out = {
			"success":true,
			"data":{
				articles:variables.fw.serialize(articles, {
					tags:{}
				}),
				tags:tags,
				authors:variables.fw.serialize(blog.getAuthors()),
				search:id		
			}
		}

		// structA/ppend(out.data, blogData);
		variables.fw.setView("blog:main.search");
		variables.fw.setLayout("blog:main.search");
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
