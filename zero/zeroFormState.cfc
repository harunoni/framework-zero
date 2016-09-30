component accessors="true" {

	property name="name";	
	property name="currentStep";
	property name="steps";
	property name="state";
	property name="stepsOrder";
	property name="formData";
	property name="complete";

	public function init(	required steps,							
							string currentStep,
							struct clientStorage=new zeroClient().getValues()
							){

		// variables.steps = [
		// 	"select_provider",
		// 	"provide_keys",
		// 	"select_region",
		// 	"finalize"
		// ];		
		
		variables.steps = listToArray(arguments.steps);
		variables.name = hash(toString(arguments.steps));
		variables.complete = false;		
		variables.clientStorage = arguments.clientStorage;
		
		clientStorage.form_state = arguments.steps;
		// clientStorage.put("form_state", arguments.steps);

		reloadFromCache();		
		return this;
	}

	public function serialize(){
		return "foo";
	}

	public function toString(){
		return "foo";
	}

	/*
	CACHE FUNCTIONS
	 */
	public function clearFormData(){
		variables.formData = {};	
		variables.state[variables.currentStep].form_data = {};
		saveCurrentState();
		// clientStorage.getValues().form_cache[variables.name].form_data = {};
	}

	public function setFormData(required struct formData){
		if(!hasFormCache()){
			resetFormCache();
		}

		if(!structKeyExists(clientStorage.form_cache[variables.name], "form_data")){
			clientStorage.form_cache[variables.name].form_data = {};
		}

		var reservedWords = new zeroReservedWords();
		var fieldsToSave = {};

		for(var key in formData){
			if(!reservedWords.has(key)){				
				fieldsToSave.insert(key, formData[key], true);				
			}			
		}
		variables.formData = fieldsToSave;
		saveCurrentState();
		reloadFromCache();
	}

	public function resetFormCache(){
		clientStorage.form_cache[variables.name] = {
			steps:variables.steps,
			name:variables.name,
			current_step:variables.currentStep?:variables.steps[1],
			state:variables.state?:{},
			form_data:{},
			complete:false,
		};
	}

	public function reloadFromCache(){
		if(!hasFormCache()){
			resetFormCache();			
		} 		
		var cache = getFormCache();		
		variables.steps = cache.steps;
		variables.name = cache.name;
		variables.currentStep = cache.current_step;
		variables.state = cache.state;
		variables.formData = cache.form_data?:{};
		variables.complete = cache.complete?:false;
	}

	public function deleteFormCache(){
		structDelete(clientStorage.form_cache, variables.name);
	}

	public function getFormCache(){
		return clientStorage.form_cache[variables.name];
	}

	public boolean function hasFormCache(){
		if(!clientStorage.keyExists("form_cache")){
			clientStorage.form_cache = {};
		}
		return clientStorage.form_cache.keyExists(variables.name);
	}	

	public function saveCurrentState(){
		saveStateKeyValue("steps", variables.steps);
		saveStateKeyValue("name", variables.name);
		saveStateKeyValue("current_step", variables.currentStep);
		saveStateKeyValue("state", variables.state);
		saveStateKeyValue("complete", variables.complete);		
		saveStateKeyValue("form_data", variables.formData);
	}

	public function saveStateKeyValue(key, value){
		if(!hasFormCache()){
			resetFormCache();
		}

		var formCache = getFormCache();
		formCache[key] = value;
	}

	/*
	FORM FUNCTIONS
	 */
	public function setState(required string step, required boolean show, required boolean complete, struct formData){
		// writeDump(arguments);
		if(!variables.state.keyExists(step)){
			variables.state[step] = {}
		}

		variables.state[step].append({show:show, complete:complete});

		if(arguments.keyExists("formData")){
			variables.state[step].form_data = duplicate(arguments.formData);
		}
	}

	function isValidStep(step){
		return arrayFindNoCase(variables.steps, step);
	}
	

	function getStepsOrder(){

		if(!variables.keyExists("stepsOrder")){
			var out = {};
			var step = "";
			var i = "";
			loop array="#variables.steps#" item="step" index="i"{
				out[step] = i;
			}
			variables.stepsOrder = out;			
		}
		return variables.stepsOrder;
	}

	function restoreStep(step){
		var order = getStepsOrder();
		var max = order[step];

		variables.currentStep = step;
		variables.formData = variables.state[step].form_data;
		//Set the form data for this step
		setState(step:step, show:true, complete:false, formData:variables.formData);

		//Set all later steps to not show and now completed, and clear their form data
		var end = arrayLen(steps);
		for(var i = max + 1; i <= end; i++){
			setState(step:"#steps[i]#", show:false, complete:false, formData:{});				
		}	
			
		saveCurrentState();		
	}

	function completeStep(step=variables.currentStep){

		var order = getStepsOrder();
		var max = order[step];

		if(isLast(step)){
			variables.complete = true;
			setState(step:step, show:true, complete:true, formData:variables.formData);
			saveCurrentState();
			return;
		}

		for(var i = 1; i <= max; i++){
			setState(step:"#steps[i]#", show:true, complete:true);
		}

		//Set the form data for this step
		setState(step:steps[max], show:true, complete:true, formData:variables.formData);

		//Set the step after this one to show
		setState(step:steps[max+1], show:true, complete:false, formData:{});


		var end = arrayLen(steps);

		for(var i = max + 2; i <= end; i++){
			setState(step:"#steps[i]#", show:false, complete:false, formData:{});				
		}		

		if(isLast(step)){
			variables.currentStep = step;
		} else {
			variables.currentStep = steps[max+1];
		}
		saveCurrentState();
	}

	function start(clearCache=true){
		variables.currentStep = steps[1];			
		if(clearCache){
			resetFormCache();
		}
		
		var order = getStepsOrder();
		var steps = variables.steps;
		
		setState(step:steps[1], show:true, complete:false, formData:{});

		for(var i = 2; i <= arrayLen(steps); i++){
			setState(step:"#steps[i]#", show:false, complete:false, formData:{});
		}		

		variables.complete = false;		
		saveCurrentState();
		// writeDump(this);
		// writeDump(clientStorage);
		// writeDump(request._zero.zeroClient.getNewValues());

		// abort;
	}

	function first(){		
		restoreStep(steps[1]);
	}

	function last(){
		var lastStep = variables.steps[arrayLen(variables.steps)];
		var stepBeforeLast = previousStep(lastStep);
		completeStep(stepBeforeLast);
	}

	boolean function isAfter(step){
		var currentId = getStepsOrder()[variables.currentStep];
		var expectedId = getStepsOrder()[step];

		if(currentId > expectedId){
			return true;
		} else {
			return false;
		}
	}

	boolean function isAtFirst(){
		return isFirst(variables.currentStep);
	}

	boolean function isAtLeast(step){

		var currentId = getStepsOrder()[variables.currentStep];
		var expectedId = getStepsOrder()[step];

		if(currentId >= expectedId){
			return true;
		} else {
			return false;
		}
	}

	boolean function isBefore(step){

		var currentId = getStepsOrder()[variables.currentStep];
		var expectedId = getStepsOrder()[step];

		if(currentId < expectedId){
			return true;
		} else {
			return false;
		}
	}

	boolean function isFirst(step){
		return getStepsOrder()[step] == 1;			
	}

	boolean function isLast(step){
		return getStepsOrder()[step] == arrayLen(variables.steps);	
	}

	function nextStep(step){
		return steps[getStepsOrder()[step] + 1];
	}

	function previousStep(step){
		return steps[getStepsOrder()[step] - 1];
	}

	function moveForward(){		
		completeStep(variables.currentStep);		
	}

	function moveBackward(clearStepData=false){		

		if(isFirst(variables.currentStep)){
			start(true);
		} else {			
			if(clearStepData){

				if(isFirst(previousStep(variables.currentStep))){
					start(true);
				} else {
					restoreStep(previousStep(previousStep(variables.currentStep)));
					completeStep();					
				}

			} else {
				restoreStep(previousStep(variables.currentStep));
			}			
		}
	}

	// if(arguments.keyExists("back")){			
	// 	moveBackward(current_step_submitted);			
	// } else {
	// 	if(current_step_submitted != "none"){
	// 		if(isNull(errors)){
	// 			moveForward(current_step_submitted);
	// 		} else {
	// 			completeStep(current_step_submitted);
	// 		}			
	// 	} else {
	// 		completeStep(current_step);
	// 	}			
	// }

}