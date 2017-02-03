/**
*/
import zero.validations.moment;
component accessors="true" {

	property name="articles" setter="false" type="array";
	property name="authors" setter="false" type="array";
	property name="tags" setter="false" type="array";

	public function init(contentMapping, contentPath, array fw1Routes){		
		variables.tags = [];
		variables.contentMapping = arguments.contentMapping;
		variables.contentPath = new directory(arguments.contentPath);
		variables.mapping = new mapping(contentMapping, contentPath);


		buildPostCollection();
		installContentFolders(contentMapping, new directory(contentPath));
		return this;
	}

	private function installContentFolders(required string contentMapping, required directory contentPath){

		var contentFolders = ["drafs","pages","posts","templates","authors"];


		for(var folder in contentFolders){
			var newDirectory = contentPath.append(folder).create();

		}
		
	}

	public includePath function getIncludePathFromCGI(required string pathInfo, type="posts"){

		var CGIPathInfo = new CGIPathInfo(arguments.pathInfo);
		var basePath = variables.mapping.append(arguments.type);
		var IncludePath = CGIPathInfo.toIncludePath(basePath, variables.mapping);
		return IncludePath;		
	}

	public boolean function isValidCGIPath(required string pathInfo, type="posts"){
		var pathInfo = arguments.pathInfo & ".cfm";
		var file = variables.mapping.append(arguments.type).appendFile(pathInfo);		
		if(file.exists()){
			return true;
		} else {
			return false;
		}		
	}

	public IncludePath function getTemplateIncludePath(required string templatePath){


		var basePath = variables.mapping.append("/templates/thedocs1_3_1");		
		var templateFile = basePath.appendFile(arguments.templatePath);
		// writeDump(templateFile.toString());
		// abort;
		var IncludePath = new IncludePath(templateFile, variables.mapping);
		return IncludePath;		
	}

	private function buildPostCollection(){

		var queryOut = queryNew("title,author,published_date,avatar,tags");
		variables.articles = [];
		// var pages = directoryList(path="../views/posts", listInfo="query");
		var paths = variables.mapping.append("posts").list(recurse=true);	
		// writeDump(paths);
		var mapping = "/var/www/blog.droppanel.io/subsystems/";
		
		var tags = [];
		for(var path in paths){
			if(path.isFile()){

				var canonicalUrl = new canonicalUrl(path, variables.mapping.append("posts"));
				var includePath = new includePath(path, variables.mapping);
				// structClear(request);
				savecontent variable="tempTemplate" {
					try {
						var blogData = ""
						module template="/tags/blog.cfc" variable="blogData" {
							include template="#includePath.toString()#";															
						}

						// include template="#newPath#";							
					}catch(any e){
						writeDump(includePath);
						writeDump(e);
						abort;
					}
					// structClear(request);
				}

				articleData = blogData;					
				// writeDump(articleData);
				// abort;
				var author = new author(
					name:articleData.getauthor(),
					avatar:articleData.getavatar()
				);
				addAuthor(author);


				var article = new article(
					title:new title(path).toString(),
					author:author,
					publishedDate:articleData.getpublisheddate(),
					avatar:articleData.getavatar(),
					canonicalUrl:canonicalUrl.toString(),
					summary:articleData.getSummary()

				);
				articles.append(article);					
				author.addArticle(article);

				var newTags = articleData.gettags().listToArray();
				for(var tag in newTags){
					var oTag = new tag(tag);
					this.addTag(oTag);						
					article.addTag(oTag);
					oTag.addArticle(article);
				}	

			}
		}
		// writeDump(blogData);
		// abort;

		// writeDump(expandPath("/subsystems"));
		// // abort;
		// var requestSave = duplicate(request);

		// recurseFindArticles = function(query paths, query queryOut, parent="/"){

		// 	for(var tryPath in arguments.paths){				
		// 		if(tryPath.type == "Dir"){					
		// 			var newPaths = directoryList(path="#tryPath.directory#/#tryPath.name#", listInfo="query");
		// 			var newParent = arguments.parent & "#tryPath.name#/";
		// 			recurseFindArticles(newPaths, arguments.queryOut, newParent);
		// 		} else {
		// 			var fileName = tryPath.name;
		// 			if(ignore.listContainsNoCase(fileName)){
		// 				continue;
		// 			}
		// 			// writeDump();
		// 			var newPath = tryPath.directory.replaceNoCase(mapping, "/subsystems/") & "/#fileName#";
		// 			// writeDump(newPAth);
		// 			// writeDump(expandPAth(newPAth));
		// 			// abort;
		// 			var title = tryPath.name.replaceNoCase(".cfm", "").replaceNoCase("-", " ", "all");
		// 			var tempTemplate = "";
		// 			// writeDump(newPAth);
		// 			var canonicalUrl = newPath.replaceNoCase("/subsystems/blog/views/posts", "").replaceNoCase(".cfm", "");					
					
		// 			// structClear(request);
		// 			savecontent variable="tempTemplate" {
		// 				try {
		// 					var blogData = ""
		// 					module template="/tags/blog.cfc" variable="blogData" {
		// 						include template="#newPath#";															
		// 					}

		// 					// include template="#newPath#";							
		// 				}catch(any e){
		// 					writeDump(newPath);
		// 					writeDump(e);
		// 					abort;
		// 				}
		// 				// structClear(request);
		// 			}
					
		// 			articleData = blogData;					
		// 			// writeDump(articleData);
		// 			// abort;
		// 			var author = new author(
		// 				name:articleData.getauthor(),
		// 				avatar:articleData.getavatar()
		// 			);
		// 			addAuthor(author);


		// 			var article = new article(
		// 				title:title,
		// 				author:author,
		// 				publishedDate:articleData.getpublisheddate(),
		// 				avatar:articleData.getavatar(),
		// 				canonicalUrl:canonicalUrl,
		// 				summary:articleData.getSummary()

		// 			);
		// 			articles.append(article);					
		// 			author.addArticle(article);

		// 			var newTags = articleData.gettags().listToArray();
		// 			for(var tag in newTags){
		// 				var oTag = new tag(tag);
		// 				this.addTag(oTag);						
		// 				article.addTag(oTag);
		// 				oTag.addArticle(article);
		// 			}						
					
		// 		}
		// 	}
		// }
		// recurseFindArticles(pages, queryOut);
		
		// req uest = duplicate(requestSave);	
		// writeDump(queryOut);
		// arraySort(tags,"text");
		// writeDump(tags);
		// writeDump(articles);
		// abort;

	}

	private function buildArticleCollectionOld(){

		var queryOut = queryNew("title,author,published_date,avatar,tags");
		variables.articles = [];
		var pages = directoryList(path="../views/posts", listInfo="query");
		var mapping = "/var/www/blog.droppanel.io/subsystems/";
		var ignore = "read.cfm,list.cfm";
		var tags = [];
		// writeDump(expandPath("/subsystems"));
		// // abort;
		// var requestSave = duplicate(request);

		recurseFindArticles = function(query paths, query queryOut, parent="/"){

			for(var tryPath in arguments.paths){				
				if(tryPath.type == "Dir"){					
					var newPaths = directoryList(path="#tryPath.directory#/#tryPath.name#", listInfo="query");
					var newParent = arguments.parent & "#tryPath.name#/";
					recurseFindArticles(newPaths, arguments.queryOut, newParent);
				} else {
					var fileName = tryPath.name;
					if(ignore.listContainsNoCase(fileName)){
						continue;
					}
					// writeDump();
					var newPath = tryPath.directory.replaceNoCase(mapping, "/subsystems/") & "/#fileName#";
					// writeDump(newPAth);
					// writeDump(expandPAth(newPAth));
					// abort;
					var title = tryPath.name.replaceNoCase(".cfm", "").replaceNoCase("-", " ", "all");
					var tempTemplate = "";
					// writeDump(newPAth);
					var canonicalUrl = newPath.replaceNoCase("/subsystems/blog/views/posts", "").replaceNoCase(".cfm", "");					
					
					// structClear(request);
					savecontent variable="tempTemplate" {
						try {
							var blogData = ""
							module template="/tags/blog.cfc" variable="blogData" {
								include template="#newPath#";															
							}

							// include template="#newPath#";							
						}catch(any e){
							writeDump(newPath);
							writeDump(e);
							abort;
						}
						// structClear(request);
					}
					
					articleData = blogData;					
					// writeDump(articleData);
					// abort;
					var author = new author(
						name:articleData.getauthor(),
						avatar:articleData.getavatar()
					);
					addAuthor(author);


					var article = new article(
						title:title,
						author:author,
						publishedDate:articleData.getpublisheddate(),
						avatar:articleData.getavatar(),
						canonicalUrl:canonicalUrl,
						summary:articleData.getSummary()

					);
					articles.append(article);					
					author.addArticle(article);

					var newTags = articleData.gettags().listToArray();
					for(var tag in newTags){
						var oTag = new tag(tag);
						this.addTag(oTag);						
						article.addTag(oTag);
						oTag.addArticle(article);
					}						
					
				}
			}
		}
		recurseFindArticles(pages, queryOut);
		
		// req uest = duplicate(requestSave);	
		// writeDump(queryOut);
		// arraySort(tags,"text");
		// writeDump(tags);
		// writeDump(articles);
		// abort;

	}

	private void function addTag(required tag tag){		
		
		variables.tags = variables.tags?:[];
		var tag = arguments.tag;
		var find = variables.tags.find(function(findTag){
			if(findTag.getTag() == tag.getTag()){
				return true;
			} else {
				return false;
			}
		});		
		if(!find){
			variables.tags.append(arguments.tag);					
		}
	}

	private void function addAuthor(required author author){
		variables.authors = variables.authors?:[];
		var author = arguments.author;
		var find = variables.authors.find(function(findauthor){
			if(findauthor.getName() == author.getName()){
				return true;
			} else {
				return false;
			}
		});		
		if(!find){
			variables.authors.append(arguments.author);					
		}
	}

	public article function findArticle(required string title){

		var title = arguments.title;
		found = variables.articles.find(function(article){
			if(article.getTitle() == title){
				return true;
			} else {
				return false;
			}
		});

		if(found){
			return variables.articles[found];
		}else {
			throw("Could not find that article");
		}
	}

	public article[] function findArticlesByTag(required string tag){
		var tagName = arguments.tag
		var found = variables.articles.filter(function(article){

			for(var tag in article.getTags()){
				if(tag.getTag() == tagName){
					return true;
				}
			}

			return false;
		});
		return found;
	}

	public article[] function getArticles(sort="publishedDate", dir="asc"){
		var sort = arguments.sort;
		var dir = arguments.dir;	
		var out = variables.articles.sort(function(first, second){
			switch(sort){
				case "publishedDate":

					var first = new moment(first.getPublishedDate());
					var second = new moment(second.getPublishedDate());

					if(first.isBefore(second)){
						return -1;
					}

					if(first.isSame(second)){
						return 0;
					}

					if(first.isAfter(second)){
						return 1;
					}
				break;
			}
		});
		if(dir=="desc") out=out.reverse();
		return out;
	}

	public authors[] function getUniqueTags(required article[] articles){

		var tags = [];
		for(var article in articles){

		}


	}

	public function distinct(required array items){
		out = [];
		var hasItem = function(haystack, needle){		
			if(haystack.len() == 0){
				return false;
			} else {
				for(var find in haystack){
					if(find.equals(needle)){
						return true;
					}
				}
				return false;
			}
		}
		for(var item in items){
			if(!hasItem(out, item)){
				out.append(item);
			}		
		}
		return out;
	}

}