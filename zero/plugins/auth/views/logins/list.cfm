<!DOCTYPE html>
<html>
<cfoutput>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="../../favicon.ico">

    <title>Framework Zero Progressive Enhangement Examples</title>

    <!-- Bootstrap core CSS -->
    <link href="/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <link href="/assets/vendor/bootstrap/css/ie10-viewport-bug-workaround.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="/assets/css/navbar-fixed-top.css" rel="stylesheet">

    <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
    <!--[if lt IE 9]><script src="/assets/vendor/bootstrap/js/ie8-responsive-file-warning.js"></script><![endif]-->
    <script src="/assets/vendor/bootstrap/js/ie-emulation-modes-warning.js"></script>

    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">


    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->



    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="/assets/vendor/bootstrap/js/vendor/jquery.min.js"><\/script>')</script>
    <script src="/assets/vendor/bootstrap/js/bootstrap.min.js"></script>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <!--- <script src="/assets/vendor/bootstrap/js/ie10-viewport-bug-workaround.js"></script> --->

</head>

<body>
    <cf_handlebars context="#rc#">
    <div class="container">
        <div class="row">
            <div class="col-md-4 col-md-offset-4">
                <div style="text-align:center; margin-top:100px; margin-bottom:20px;">
                    <img src="/letsflycheaper/assets/img/logo.png" />
                </div>
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <cfif structKeyExists(rc,"id")>
                            <div class="alert alert-success" style="margin-bottom:0px;">
                                Welcome to #CGI.server_name#, please create a password to complete the setup of your account.
                            </div>
                        <cfelse>
                            <cfif structKeyExists(rc,"message")>
                                <div class="alert alert-success" style="margin-bottom:0px;">
                                #rc.message#
                                </div>
                            <cfelse>
                                <h3 class="panel-title">Please Sign In</h3>
                            </cfif>
                        </cfif>
                    </div>
                    <div class="panel-body">
                        <form role="form" method="POST" action="{{##if data.user.id}}/auth/logins/{{data.user.id}}{{else}}/auth/logins{{/if}}">
                            <fieldset>
                                {{##if data.user.id}}
                                    <input value="{{data.id}}" type="hidden" name="id">
                                    <div class="form-group">
                                        <input class="form-control" placeholder="E-mail" name="email_address" type="email" value="{{data.user.email}}" disabled="true">
                                    </div>
                                    <div class="form-group">
                                        <input class="form-control" placeholder="Password" name="password" type="password" value="">
                                    </div>
                                    <div class="form-group">
                                        <input class="form-control" placeholder="Confirm Password" name="confirmpassword" type="password" value="">
                                    </div>
                                {{else}}
                                    <div class="form-group">
                                        <input class="form-control" placeholder="E-mail" name="email_address" type="email" autofocus value="">
                                    </div>
                                    <div class="form-group">
                                        <input class="form-control" placeholder="Password" name="password" type="password" value="">
                                    </div>
                                    <div class="checkbox">
                                        <label>
                                            <input name="remember" type="checkbox" value="Remember Me" onClick="Javascript: $('##loginLength').toggle();">Remember Me
                                        </label>
                                    </div>
                                    <div id="loginLength" class="checkbox" style="display:none;">
                                        <label>For: </label>
                                            <select name="length" type="checkbox">
                                                <option value="1">One Day</option>
                                                <option value="7">One Week</option>
                                                <option value="30">One Month</option>
                                                <option value="365">One Year</option>
                                            </select>
                                    </div>
                                {{/if}}


                                <!-- Change this to a button or input when using this as a form -->
                                <button name="login" class="btn btn-lg btn-info btn-block">Login</button>
                                <input name="goto" type="hidden" value="{{data.goto}}"/>
                                <input type="hidden" name="goto_fail" value="/auth/logins" />
                            </fieldset>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </cf_handlebars>

    <!-- Core Scripts - Include with every page -->
    <script src="/assets/js/jquery-1.10.2.js"></script>
    <script src="/assets/js/bootstrap.min.js"></script>
    <script src="/assets/js/plugins/metisMenu/jquery.metisMenu.js"></script>

    <!-- SB Admin Scripts - Include with every page -->
    <script src="/assets/js/sb-admin.js"></script>

</body>
</cfoutput>
</html>
<cfset request.layout = false>
