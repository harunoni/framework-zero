/**
*/
component accessors="true"{

	property name="name" setter="false" type="string";
	property name="avatar" setter="false" type="string";
	property name="articles" setter="false" type="array";
	property name="canonicalUrl" setter="false" type="string";

	public function init(required string name,
						 required string avatar){
		variables.name = arguments.name;
		variables.avatar = arguments.avatar;
		return this;
	}

	public void function addArticle(required Article Article){
		variables.Articles = variables.Articles?:[];
		var Article = arguments.Article;
		var find = variables.Articles.find(function(findArticle){
			if(findArticle.getTitle() == Article.getTitle()){
				return true;
			} else {
				return false;
			}
		});		
		if(!find){
			variables.Articles.append(arguments.Article);					
		}
	}

	public function getCanonicalUrl(){
		return lcase(variables.name.replaceNoCase(" ","-","all"));
	}
}