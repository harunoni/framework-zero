/**
*/
component persistent="true" table="events" implements="event" {

	property name="id" fieldtype="id" generator="native";
	property name="name";
	property name="lookupName";
	property name="createdAt" column="created_at" type="datetime" dbdefault="CURRENT_TIMESTAMP";
	property name="payload" type="string" sqltype="text";
	property name="eventLog" fieldtype="many-to-one" cfc="eventLog" fkcolumn="event_log_id" inverse="true";

	public function init(){
		return this;
	}
}