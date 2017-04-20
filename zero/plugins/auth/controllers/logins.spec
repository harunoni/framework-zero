<cfscript>
	spec = {
		url:"#CGI.http_host#/auth/logins",
		tests:{
			"/.json":{				
				POST:{
					"Should create a new login":{
						given:{
							formFields:{
								email:"testuser@raakaventures.com",
								password:123456
							}
						},
						then:{
							returns:"isJson",
							fileContent:function(json, given){
								assert(json.message IS "The login was successfully created");								
								return true;
							}
						},
						afterTests:function(response){
							local.userHash = deserializeJson(response.fileContent).credentials.token;							
							local.authentication = deserializeJson(response.fileContent).credentials.authentication;	
							local.login = entityLoad("logins",{userHash:local.userHash, passcode:hash(local.authentication,"SHA-256")}, true);
							entityDelete(local.login);
							ORMFlush();
						}						
					},					
				}
			}			
		}
	}
</cfscript>