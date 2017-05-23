/**
 * Represents a configured event log that will take events.
*/
component persistent="true" implements="eventLog" table="event_logs" {

	property name="id" fieldtype="id" generator="native";
	property name="name" type="string";
	property name="lookupName" type="string";
	property name="zeroEvent" fieldtype="many-to-one" cfc="zeroEvent" fkcolumn="zero_event_id" inverse="true";
	property name="events" fieldtype="one-to-many" cfc="event" fkcolumn="event_log_id" singularname="event";
	property name="logReaders" fieldtype="one-to-many" cfc="logReader" fkcolumn="event_log_id" singularname="logReader";

	public function init(){
		return this;
	}

	public Event function createEvent(required name, required payload){
		var Event = entityNew("sqlEvent", {name:arguments.name, lookupName:lcase(arguments.name), payload:arguments.payload});
		entitySave(Event);
		this.addEvent(Event);
		Event.setEventLog(this);
		return Event;
	}

	public Optional function getEventAfter(required numeric lastId){
		var Event = ORMExecuteQuery("
			SELECT e
			FROM sqlEvent e
			JOIN e.eventLog el
			WHERE el.id = #this.getId()#
			AND e.id > #arguments.lastId#
			ORDER BY e.id ASC", {} , true, {maxResults:1});
		if(isNull(Event)){
			return new Optional();
		} else {
			return new Optional(Event);
		}
	}
}