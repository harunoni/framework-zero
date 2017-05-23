/**
 * The entry point for the ZeroEvent plugin application
*/
component persistent="true" table="zero_event" {

	property name="id" fieldtype="id" generator="native";
	property name="eventLogs" fieldtype="one-to-many" cfc="eventLog" fkcolumn="zero_event_id" singularname="eventLog";
	property name="logReaders" fieldtype="one-to-many" cfc="logReader" fkcolumn="zero_event_id" singularname="logReader";

	public function init(){
		return this;
	}

	public EventLog function createEventLog(name=""){
		var EventLog = entityNew("SQLEventLog",{name:arguments.name, lookupName:lcase(arguments.name)});
		entitySave(EventLog);
		this.addEventLog(EventLog);
		EventLog.setZeroEvent(this);
		return EventLog;
	}

	public function createLogReader(required string name="", required EventLog EventLog){

		var LogReader = entityNew("logReader",{name:arguments.name, lookupName:lcase(arguments.name)});
		entitySave(LogReader);
		this.addLogReader(LogReader);
		LogReader.setZeroEvent(this);

		EventLog.addLogReader(LogReader);
		LogReader.setEventLog(EventLog);
		return LogReader;
	}

	package EventLog function createOrLoadEventLog(required string name){

		var EventLogOptional = findEventLogByName(arguments.name);
		if(EventLogOptional.exists()){
			return EventLogOptional.get()
		}
		var EventLog = createEventLog(arguments.name);
		return EventLog;
	}

	public Optional function findEventLogByName(required string name){
		var EventLog = entityLoad("SQLEventLog",{lookupName:lcase(arguments.name)}, true);
		if(isNull(EventLog)){
			return new Optional();
		} else {
			return new Optional(EventLog);
		}
	}

	public boolean function raiseEvent(required string logName, required string eventName, required any payload){
		var EventLog = createOrLoadEventLog(arguments.LogName);
		var Event = EventLog.createEvent(arguments.eventName, arguments.payload);
		ORMFlush();
		entityReload(EventLog);
		return true;
	}

}