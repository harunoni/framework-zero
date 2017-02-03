<cfscript>
function setdateOfBirth(value){
if(isInstanceof(arguments.value, 'dateOfBirth')){
variables.dateOfBirth = arguments.value.toString();
} else {
variables.dateOfBirth = new dateOfBirth(value=arguments.value).toString();
}
}
function getdateOfBirth(value){
if(isNull(variables.dateOfBirth)){
return nullValue()
} else {
return new dateOfBirth(value=variables.dateOfBirth?:nullValue());
}
}
</cfscript>