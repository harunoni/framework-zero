component accessors="true" {

	property name="name";	
	property name="currentStep";
	property name="steps";
	property name="state";
	property name="stepsOrder";
	property name="formData";
	property name="complete";

	public function init(	required steps,							
							string currentStep
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
		client.form_state = arguments.steps;

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
		client.form_cache[variables.name].form_data = {};
	}

	public function setFormData(required struct formData){
		if(!hasFormCache()){
			resetFormCache();
		}
		client.form_cache[variables.name].form_data.append(formData);
	}

	public function resetFormCache(){
		client.form_cache[variables.name] = {
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
		variables.formData = cache.form_data;
		variables.complete = cache.complete?:false;
	}

	public function deleteFormCache(){
		structDelete(client.form_cache, variables.name);
	}

	public function getFormCache(){
		return client.form_cache[variables.name];
	}

	public boolean function hasFormCache(){
		if(!client.keyExists("form_cache")){
			client.form_cache = {};
		}
		return client.form_cache.keyExists(variables.name);
	}	

	public function saveCurrentState(){
		saveStateKeyValue("steps", variables.steps);
		saveStateKeyValue("name", variables.name);
		saveStateKeyValue("current_step", variables.currentStep);
		saveStateKeyValue("state", variables.state);
		saveStateKeyValue("complete", variables.complete);		
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
	public function setState(required string step, required boolean show, required boolean complete){
		// writeDump(arguments);
		if(!variables.state.keyExists(step)){
			variables.state[step] = {}
		}

		variables.state[step].append({show:show, complete:complete})
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

	function completeStep(step){

		var order = getStepsOrder();
		var max = order[step];

		if(isLast(step)){
			variables.complete = true;
			setState(step:step, show:true, complete:true);
			saveCurrentState();
			return;
		}

		setState(step:steps[max+1], show:true, complete:false);

		for(var i = 1; i <= max; i++){
			setState(step:"#steps[i]#", show:true, complete:true);
		}

		var end = arrayLen(steps);

		for(var i = max + 2; i <= end; i++){
			setState(step:"#steps[i]#", show:false, complete:false);				
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
		
		setState(step:steps[1], show:true, complete:false);

		for(var i = 2; i <= arrayLen(steps); i++){
			setState(step:"#steps[i]#", show:false, complete:false);
		}		

		variables.complete = false;		

		saveCurrentState();
	}

	function first(){		
		start(false);
	}

	function last(){
		var lastStep = variables.steps[arrayLen(variables.steps)];
		var stepBeforeLast = previousStep(lastStep);
		completeStep(stepBeforeLast);
	}

	function isAtFirst(){
		return isFirst(variables.currentStep);
	}

	function isFirst(step){
		return getStepsOrder()[step] == 1;			
	}

	function isLast(step){
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

	function moveBackward(){		

		if(isFirst(variables.currentStep) OR isFirst(previousStep(variables.currentStep))){
			start(false);
		} else {
			var twoStepsBack = previousStep(previousStep(variables.currentStep));
			completeStep(twoStepsBack);
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