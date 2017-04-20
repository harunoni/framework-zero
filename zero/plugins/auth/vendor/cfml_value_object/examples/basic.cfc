/**
 * A basic value object with a single value
 * @type {String}
 */
component extends="valueObject" {

	property name='value';

	public function init(required string value){
		variables.value = arguments.value;
	}

}