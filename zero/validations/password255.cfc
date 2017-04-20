/*
Trims an incoming password to the preceding 255 characters. We do not limit the
total password length, but discard the trailing characters after 255
so as to not unnecessarily slow down the password hasing
 */
component extends="valueObject" {
	public valueObject function init(any value){
		variables.value = left(arguments.value, 255);
		return this;
	}
}