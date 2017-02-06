component accessors="true" {    
	
	public any function init( fw ) {		
		variables.fw = fw;		
		return this;
	}

	public struct function new( rc ) {
    	return {};
	}
	
	public struct function list( rc ) {
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
    	return {};
	}

	public struct function update( rc ) {
    	return {};
	}

	public struct function delete( rc ) {
    	return {};
	}

	public struct function pricing( rc ){
		return {};
	}

	public struct function alpha( rc ){
		return {};
	}	
	
}
