/**
*/
component accessors="true"{

	property name="title" setter="true";
	property name="author" setter="false" type="author";
	property name="publishedDate" setter="false";
	property name="avatar" setter="false";
	property name="tags" setter="false" type="array";
	property name="canonicalUrl" setter="false" type="string";
	property name="summary";

	public function init(required string title,
						 required author author,
						 required string publishedDate,
						 required string avatar,
						 required string canonicalUrl,
						 required string summary,
						 ){
		variables.title = arguments.title;
		variables.author = arguments.author;
		variables.publishedDate = arguments.publishedDate;
		variables.avatar = arguments.avatar;
		variables.canonicalUrl = arguments.canonicalUrl;
		variables.tags = [];		
		variables.summary = arguments.summary;
		return this;
	}

	public function addTag(required tag tag){
		variables.tags.append(arguments.tag);
	}
}