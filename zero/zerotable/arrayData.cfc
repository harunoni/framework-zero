/**
*/
component implements="data"{
	public function init(required array data){
		variables.data = arguments.data;
		return this;
	}


	public numeric function count(){
		return arrayLen(variables.data);
	}

	public array function list(required string max, required string offset){
		return variables.data;
	}

	public void function search(required string searchString){
		// throw("not implemented");
	}

	public function sort(required string column, required string direction){		
		return variables.data;
	}
}