/**
 * Keeps track of a particular event log and the position of the log which
 * has been read
*/
component persistent="true" table="event_readers" {

	property name="id" fieldtype="id" generator="native";
	property name="name";
	property name="lookupName";
	property name="lastEventId" type="numeric" default="0" dbdefault="0";
	property name="eventLog" fieldtype="many-to-one" cfc="eventLog" fkcolumn="event_log_id" inverse="true";
	property name="zeroEvent" fieldtype="many-to-one" cfc="zeroEvent" fkcolumn="zero_event_id" inverse="true";

	public function init(){
		return this;
	}

	public function next(function func){
		lock name="logReaderNext" timeout="10" {
			var Event = getEventLog().getEventAfter(this.getLastEventId());
			if(Event.exists()){
				var Event = Event.get();
				if(arguments.keyExists("func")){
					func(Event);
				}
				this.setLastEventId(Event.getId());
				ORMFlush();
				entityReload(this);
			}
		}
	}

	public function previous(){

	}

	public function first(){

	}

	public function last(){

	}

}