/**
 * A value object that takes a complex value (not a string, numeric or boolean)
 * @type {String}
 */
component extends="valueObject" {

	property name='value';

	public function init(required struct value){
		variables.value = arguments.value;
	}

}