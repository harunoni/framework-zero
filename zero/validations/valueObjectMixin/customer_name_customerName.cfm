<cfscript>
function setname(value){
if(isInstanceof(arguments.value, 'customerName')){
variables.name = arguments.value.toString();
} else {
variables.name = new customerName(value=arguments.value).toString();
}
}
function getname(value){
if(isNull(variables.name)){
return nullValue()
} else {
return new customerName(value=variables.name?:nullValue());
}
}
</cfscript>