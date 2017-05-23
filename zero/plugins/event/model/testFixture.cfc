component {

	function createZeroEvent(){
		var ZeroEvent = entityNew("zeroEvent");
		entitySave(ZeroEvent);
		return ZeroEvent;
	}

	function createSqlEventLog(){

		var ZeroEvent = createZeroEvent();
		var SQLEventLog = ZeroEvent.createEventLog();
		ORMFlush();
		entityReload(ZeroEvent);
		return SQLEventLog;
	}

	function createSQLEvent(){
		var SQLEventLog = createSqlEventLog();
		var SQLEvent = SQLEventLog.createEvent("name","my event");
		ORMFlush();
		entityReload(SQLEventLog);
		return SQLEvent;
	}

	function createLogReader(){
		var ZeroEvent = createZeroEvent();
		var EventLog = ZeroEvent.createOrLoadEventLog("eventLog");
		var LogReader = ZeroEvent.createLogReader(name="my reader", EventLog=EventLog);
		return LogReader;
	}

}