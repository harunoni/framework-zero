# cfml_value_object
A base object for creating ValueObjects in CFML following Domain Driven Design

##Purpose
In Domain Driven Design, valueObjects are used to validate and constrain the range of inputs for any given value. valueObjects are immutable and do not have identity see [Value Objects](http://martinfowler.com/bliki/ValueObject.html) for more details.

The valueObject.cfc class provided in this repository provides some convenient default helper methods for use in Lucee applications.

##Usage
Create a component which extends valueObject and has at least one property. valueObjects should be immutable and thus all validation and instantiation should occur within the init() method. There should be no setters for the property in order to maintain immutability.

```javascript
component extends="valueObject" {
  property name='myValue';
  
  public function init(required string myValue){
      
      variables.value = arguments.value;
      return this;
    
  }
  
}
```

##Requirements
Only tested against Lucee 4.5+. Requires Closures which are on CF 10+ and Railo 4.2+

##Installation

###Traditional
Download the valueObject.cfc file and place it anywhere to use it, usually in a Util directory

###CommandBox
cfml_value_object is a CommandBox package, install it using commandBox
[Obtain CommandBox package manager](http://www.ortussolutions.com/products/commandbox)

###For Production Use
`install https://github.com/roryl/cfml_value_object/archive/master.zip --production`

###For Contributing to cfml_optional
This will install the testbox dependencies and unit tests
`install https://github.com/roryl/cfml_value_object/archive/master.zip`

##API Reference
###public string toString()
Convers your value object to a string for passing to systems which require a simple value representation of your object. This is typically for the final step of persisting to a database, or for transmitting over HTTP, writing to file, etc.

Only works with value objects which have a single property.

###public struct toStruct()
Returns all of the properties of your value object as a struct. It assumes all properties are 'public' and thus you can hide variables within your value object which are meant to be private.

###public string serialize()
Calls the Lucee serialize() function on the result of toStruct(), which may be useful for persisting the value object or other operations

###public numeric length()
Returns the length of the value of the property.

Only works with value objects which have a single property.

###public boolean equals(required valueObject ob)
Takes a value object and compares the value of the properties of the objects to each other. Override the equals() function in your value object if your comparison use case is more specific than simply comparing the values of the properties.
