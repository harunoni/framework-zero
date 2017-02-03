<cfscript>
function setemailAddress(value){
if(isInstanceof(arguments.value, 'emailAddress')){
variables.emailAddress = arguments.value.toString();
} else {
variables.emailAddress = new emailAddress(value=arguments.value).toString();
}
}
function getemailAddress(value){
if(isNull(variables.emailAddress)){
return nullValue()
} else {
return new emailAddress(value=variables.emailAddress?:nullValue());
}
}
</cfscript>