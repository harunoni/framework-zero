/**
*/
component accessors="true" {
	property name="tag" type="string" setter="false";
	property name="articles" type="array";

	public function init(required string tag){
		variables.tag = arguments.tag;
		variables.articles = [];
		return this;
	}

	public void function addArticle(required article article){
		variables.articles.append(arguments.article);
	}

	public function equals(required tag tag){
		return this.getTag() == arguments.tag.getTag();
	}
}