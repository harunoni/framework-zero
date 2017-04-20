/**
 * A value object with more than one value
 * @type {String}
 */
component extends="valueObject" {

	property name='firstValue';
	property name='secondValue';

	public function init(required string firstValue, required string secondValue){
		variables.firstValue = arguments.secondValue;
		variables.secondValue = arguments.secondValue;
	}

}