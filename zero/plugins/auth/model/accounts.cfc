/*
Author: Rory Laitila

*/

component persistent="true" table="accounts" output="false" accessors="true" discriminatorColumn="accounts_extended_by" discriminatorValue="base"
{
	/* properties */

	property name="id" column="accounts_id" type="numeric" ormtype="int" fieldtype="id" generator="identity";
	property name="name" column="accounts_name" type="string" specTestValue="RetailTestAccount" isExportSensitive="true" exportValue="Account Name";
	property name="address" column="accounts_address" type="string" specTestValue="11222 Mulberry Lane" isExportSensitive="true" exportValue="123 Some Address";
	property name="adminServer" column="accounts_admin_server" type="string" specTestValue="admin.domain.com" isExportSensitive="true" exportValue="test.com";
	property name="type" column="accounts_type" type="string" length="45" default="customer" specTestValue="customer";
	property name="status" column="accounts_status" type="string" length="45" default="enabled" specTestValue="enabled";
	property name="adminPath" column="accounts_admin_path" type="string" length="256" default="/" specTestValue="/testvalue/";

	property name="users" fieldtype="one-to-many" cfc="user" fkcolumn="user_accounts_id" lazy="false" inverse="true" singularname="user" cascade="all";
	property name="resources" fieldtype="many-to-many" cfc="resources" linktable="resources_accounts" fkcolumn="accounts_id" type="struct" structkeycolumn="resources_name" notnull="true" singularname="resource" cascade="none";
	property name="roles" fieldtype="many-to-many" cfc="roles" linktable="accounts_roles" singularname="role";
	property name="auth" fieldtype="many-to-one" cfc="auth" fkcolumn="auth_id" inverse="true";

}
