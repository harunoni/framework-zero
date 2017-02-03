/**
*/
component {
	public function init(required fw){
		variables.fw = arguments.fw;
		return this;
	}

	public function setupRoutes(required array routes){
		setupPagesRoutes(arguments.routes);
		setupBlogRoutes(arguments.routes);
		setupAuthorsRoutes(arguments.routes);
	}

	public function request(){

	}

	public function response(){

	}

	private function setupPagesRoutes(array routes) {
		
		var pages = directoryList(path="../../content/pages", listInfo="query");				
		recurseAddRoutes = function(query paths, array routes, parent="/"){

			for(var path in arguments.paths){				
				if(path.type == "Dir"){					
					var newPaths = directoryList(path="#path.directory#/#path.name#", listInfo="query");
					var newParent = arguments.parent & "#path.name#/";
					recurseAddRoutes(newPaths, arguments.routes, newParent);
				} else {
					var fileName = path.name;					
					var prefix = listFirst(fileName, ".");
					arguments.routes.prepend({'#arguments.parent##prefix#' = '/blog:pages/read'});
				}
			}
		}
		recurseAddRoutes(pages, arguments.routes);
		arguments.routes.append({'/drafts' = '302:/'});				
		arguments.routes.append({'/^' = '/home:main/list'});			
	}

	private function setupAuthorsRoutes(array routes) {
		
		var pages = directoryList(path="../../content/authors", listInfo="query");				
		recurseAddRoutes = function(query paths, array routes, parent="/"){

			for(var path in arguments.paths){				
				if(path.type == "Dir"){					
					var newPaths = directoryList(path="#path.directory#/#path.name#", listInfo="query");
					var newParent = arguments.parent & "#path.name#/";
					recurseAddRoutes(newPaths, arguments.routes, newParent);
				} else {
					var fileName = path.name;					
					var prefix = listFirst(fileName, ".");
					arguments.routes.prepend({'/authors#arguments.parent##prefix#' = '/blog:authors/read'});
				}
			}
		}
		recurseAddRoutes(pages, arguments.routes);
		arguments.routes.append({'/drafts' = '302:/'});				
		arguments.routes.append({'/^' = '/home:main/list'});			
	}

	private function setupBlogRoutes(array routes) {		
		var pages = directoryList(path="../../content/posts", listInfo="query");				
		recurseAddRoutes = function(query paths, array routes, parent="/"){

			for(var path in arguments.paths){				
				if(path.type == "Dir"){					
					var newPaths = directoryList(path="#path.directory#/#path.name#", listInfo="query");
					var newParent = arguments.parent & "#path.name#/";
					recurseAddRoutes(newPaths, arguments.routes, newParent);
				} else {
					var fileName = path.name;					
					var prefix = listFirst(fileName, ".");
					arguments.routes.prepend({'#arguments.parent##prefix#' = '/blog:posts/read'});
				}
			}
		}
		recurseAddRoutes(pages, arguments.routes);
		arguments.routes.append({'/drafts' = '302:/'});				
		arguments.routes.append({'/^' = '/home:main/list'});					
	}
}