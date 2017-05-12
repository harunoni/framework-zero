<div class="container">
    <div class="row">
        <div class="col-md-4 col-md-offset-4">
            <div class="login-panel panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title">Create the default super user</h3>
                </div>
                <div class="panel-body">
                    <form role="form" method="post" action="/auth/super_users">
                        <input type="hidden" name="goto" value="/">
                        <fieldset>
                            <div class="form-group">
                                <input class="form-control" placeholder="E-mail" name="email_address" type="email" autofocus>
                            </div>
                            <div class="form-group">
                                <input class="form-control" placeholder="Password" name="password" type="password" value="">
                            </div>
                            <div class="form-group">
                                <input class="form-control" placeholder="First Name" name="first_name" value="">
                            </div>

                            <div class="form-group">
                                <input class="form-control" placeholder="Last Name" name="last_name" value="">
                            </div>
                            <!-- Change this to a button or input when using this as a form -->
                            <input type="submit" class="btn btn-lg btn-success btn-block" value="CREATE SUPER USER" />
                        </fieldset>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>