component accessors="true" {

    property beanFactory;
    property formatterService;

	public any function init( fw ) {
		variables.fw = fw;
		return this;
	}

	public void function default( rc ) {
       writeDump(form);
	}

	public function list(){
		return {}
	}

}
