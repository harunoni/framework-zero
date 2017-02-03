component accessors="true" {    
	
	public any function init( fw ) {
		variables.fw = fw;
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

	public struct function read( rc ) {
    	return {};
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
