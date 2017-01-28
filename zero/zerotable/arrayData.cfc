/**
*/
component implements="data"{
	public function init(required array data){
		variables.data = arguments.data;
		return this;
	}

	public function sort(required string column, required string direction){		
		return variables.data;
	}

	public int function count(){
		return arrayLen(variables.data);
	}

	public array function list(required string max, required string offset){
		return variables.data;
	}

}