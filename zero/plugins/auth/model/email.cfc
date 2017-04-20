/**
*
* @file  /C/websites/dev.letsflycheaper.com/auth/model/orm/emails.cfc
* @author  Rory Laitila
* @description Represents emails sent to user for user account management
*
*/
component persistent="true" table="emails" accessors="true" discriminatorColumn="emails_extended_by"{

	property name="id" column="emails_id" type="numeric" ormtype="int" fieldtype="id" generator="identity";
	property name="dateSent" column="emails_date_sent" sqltype="timestamp" generated="always" default="CURRENT_TIMESTAMP";
	property name="from" column="emails_from" type="string" length="255" default="letsflycheaper@raakaventures.com" isExportSensitive="true" exportValue="test@raakaventures.com";
	property name="to" column="emails_to" type="string" length="255" isExportSensitive="true" exportValue="totest@raakaventures.com";
	property name="subject" column="emails_subject" type="string" length="255";
	property name="template" column="emails_template" type="string" length="255";
	property name="htmlContent" column="emails_content" type="string" sqltype="text" isExportSensitive="true" exportValue="HTML Output";
	property name="plainContent" column="emails_plain_content" type="string" sqltype="text" isExportSensitive="true" exportValue="Plain Text Email";
	property name="isSent" column="emails_is_sent" type="boolean";
	property name="failMessage" column="emails_failure_message" type="string" sqltype="text";

	//Used to connect to the server to send the email but we do not save these
	property name="server" persistent="false" default="";
	property name="useTLS" persistent="false" default="false";

	property name="password" persistent="false" default="";
	property name="port" persistent="false" default="";
	property name="username" persistent="false" default="";

	public function init(){

	}

	public function send(){
		mail from="#variables.from#"
						async="false"
						to="#variables.to#"
						usetls="#variables.usetls#"
						username="#variables.username#"
						password="#variables.password#"
						server="#variables.server#"
						port="#variables.port#"
						subject="#variables.subject#"{
						mailpart type="text/plain"{echo("#variables.plaincontent#");}
						mailpart type="text/html"{echo("#variables.htmlcontent#");}
						}
	}

	// public function init(){

	// 	variables.emailer = new emailer(server = variables.server,
	// 				useTLS = variables.useTLS,
	// 				password = variables.password,
	// 				port = variables.port,
	// 				username = variables.username,
	// 				templateLocation = variables.templateLocation);
	// 	return this;
	// }

	// public function sendEmail(required struct data){
	// 	variables.emailer.sendMail(from = variables.from,
	// 							   to = variables.to,
	// 							   template = variables.template,
	// 							   subject = variables.subject,
	// 							   data = arguments.data);
	// }
}