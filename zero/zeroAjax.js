var lastButtonClickedValue = {};

zeroAjax = function(html){
	var zeroForms = $(html).find('form[zero-target]');
	$(zeroForms).off('submit');

	for(var i=0 ; i < zeroForms.length; i++){

		var action = $(zeroForms[i]).attr('action');
		var goto = $(zeroForms[i]).find('input[name=goto]').val();
		var currentPath = window.location.pathname;
		
		
		var gotoAndCurrentPathAreTheSame = true;
		// var gotoAndCurrentPathAreTheSame = (goto == currentPath);
		
		if(gotoAndCurrentPathAreTheSame){
			$(zeroForms[i]).on('submit',function(event){

				var event = event;
				event.preventDefault();
				// console.log(event);

				var form = $(event.target);
				console.log(form);
				console.log(form[0].action);
				var target = form.attr('zero-target');
				var formButton = $(form).find('button');					
				var icon = $(formButton).find('i');
				// console.log(icon.hasClass('fa'));

				var oldClass = icon.attr('class');

				if(icon.hasClass('fa-refresh')){
					icon.addClass('fa-spin');						
				} else {
					icon.removeClass();
					icon.addClass('fa fa-circle-o-notch fa-spin');
					console.log('buttons');
					// alert();
				}

				formButton.attr('disabled', true);

				// var data = form.serialize();
				// console.log(data);

				// Use Ajax to submit form data. Add the button value to the submit					
				var formData = form.serializeArray();					
				formData.push(lastButtonClickedValue);

				/*
				Check if the last button clicked had a formaction. This is a HTML5
				feature to send forms to a different URL. If so, this needs to override the
				form's action. There is no way in Javascript cross browser, to get the
				button's formaction from the onSubmit event.
				
				We need to know what button the user last clicked to determine if we are to
				load the form action from the button, or to load it from
				the form's action.
				 */					
				if(typeof lastButtonClickedElement != 'undefined' && lastButtonClickedElement){
					var buttonHasFormAction = $(lastButtonClickedElement).attr('formaction');
					if(typeof buttonHasFormAction != 'undefined' && buttonHasFormAction){
						var formAction = buttonHasFormAction;
					} else {
						var formAction = form.attr('action');
					}											
				} else {
					var formAction = form.attr('action');
				}

				console.log(formAction);

	            $.ajax({
	                url: formAction,
	                type: 'POST',
	                data: formData,
	                success: function(result) {
	                    
	                    //http://stackoverflow.com/questions/405409/use-jquery-selectors-on-ajax-loaded-html
	                    //
	                    
	                    // http://stackoverflow.com/questions/14423257/find-body-tag-in-an-ajax-html-response
	                    if(target == 'body'){
	                    	var targetHTML = result.substring(result.indexOf("<body>")+6,result.indexOf("</body>"));                    	
							
							

							var targetPut = $('body');		                    
	                    	targetPut.html(targetHTML);
	                    } else {
	                    	// console.log(result);
	                		var response = $('<html />').html(result);
	                		
	                		/*
	                		The target can be a comma separated list of targets. This is useful for updating a number
	                		of sections on the page based on the response
	                		 */
	                    	var targetArray = target.split(',');
	                    	
	                    	for(var i=0; i < targetArray.length; i++){
	                    		
		                    	var targetHTML = $(response).find(targetArray[i]);
		                    	// console.log(targetHTML);
		                    	var targetPut = $(targetArray[i]);
		                    	if(!targetPut.length){
		                    		throw "Could not find the target " + targetArray[i] + " check your references and ensure it exists";
		                    	}
		                    	// console.log(targetPut);		                    
		                    	targetPut.html(targetHTML.html());
	                    	}
	                    	
	                    	formButton.removeAttr('disabled');                    	
	                    }

	                    /* Undo the last button clicked because we do not want this to interfere with subsequent zero-autos
	                    */		                    
	                    delete lastButtonClickedElement;

	                    icon.removeClass();
	                    icon.addClass(oldClass);
	               
	                    //Call zeroAjax over the document again to add event listeners
	                    zeroInit();
	                    // console.log(targetHTML);
	                }
	            });
			})
		}
	}
	
}

/**
 * Implements the Zero Ajax progressive enhancement feature for anchorlinks 
 */
zeroAjaxAnchor = function(html){

	var zeroAnchors = $(html).find('a[zero-target]');
	$(zeroAnchors).off('submit');

	for(var i=0 ; i < zeroAnchors.length; i++){

		var anchorAction = $(zeroAnchors[i]).attr('href');
		
		var currentPath = window.location.pathname;
		
		
		var gotoAndCurrentPathAreTheSame = true;
		// var gotoAndCurrentPathAreTheSame = (goto == currentPath);
		
		if(gotoAndCurrentPathAreTheSame){
			$(zeroAnchors[i]).on('click',function(event, selector){

				var event = event;
				
				event.preventDefault();
				// console.log(event);

				var anchor = $(this);
				anchorAction = $(anchor).attr('href');
				var target = anchor.attr('zero-target');
				// console.log(anchor);
				// throw"";
				// var anchor = $(anchor).find('button');					
				var icon = $(anchor).find('i');
				// console.log(icon.hasClass('fa'));

				var oldClass = icon.attr('class');

				if(icon.hasClass('fa-refresh')){
					icon.addClass('fa-spin');						
				} else {
					icon.removeClass();
					icon.addClass('fa fa-circle-o-notch fa-spin');
					console.log('buttons');
					// alert();
				}

				anchor.attr('disabled', true);
			

				// console.log(anchorAction);

	            $.ajax({
	                url: anchorAction,
	                type: 'GET',	                
	                success: function(result) {
	                	
	                    // http://stackoverflow.com/questions/14423257/find-body-tag-in-an-ajax-html-response
	                    if(target == 'body'){
	                    	var targetHTML = result.substring(result.indexOf("<body>")+6,result.indexOf("</body>"));      
							var targetPut = $('body');		                    
	                    	targetPut.html(targetHTML);
	                    } else {
	                    	// console.log(result);
	                		var response = $('<html />').html(result);
	                		
	                		/*
	                		The target can be a comma separated list of targets. This is useful for updating a number
	                		of sections on the page based on the response
	                		 */
	                    	var targetArray = target.split(',');
	                    	
	                    	for(var i=0; i < targetArray.length; i++){
	                    		
		                    	var targetHTML = $(response).find(targetArray[i]);
		                    	// console.log(targetHTML);
		                    	var targetPut = $(targetArray[i]);
		                    	if(!targetPut.length){
		                    		throw "Could not find the target " + targetArray[i] + " check your references and ensure it exists";
		                    	}
		                    	// console.log(targetPut);		                    
		                    	targetPut.html(targetHTML.html());
	                    	}
	                    	
	                    	anchor.removeAttr('disabled');                    	
	                    }	                   

	                    icon.removeClass();
	                    icon.addClass(oldClass);
	               
	                    //Call zeroAjax over the document again to add event listeners
	                   zeroInit();	                   
	                }
	            });
			})
		}
	}

}

/**
 * Used by zeroAjax to determine which button was clicked when 
 * overriding form action with HTML button formaction attribute 
 */
var lastButtonClicked = function(html){
	lastButtonClickedValue = {};
	var formButtons = $(html).find('button,input[type="submit"]');
	formButtons.each(function(index, button){
		$(button).on("click",function(element){
			lastButtonClickedElement = this;
			lastButtonClickedValue = { name: this.name, value: this.value };
			console.log(lastButtonClickedValue);
		})
	});	
}

/**
 * Automatically submits forms based on a timeout value
 * useage: 
 * 	add the property zero-auto to any form
 * 	
 * 	zero-auto="2" 
 */
zeroAuto = function(html){

	var zeroAutos = $(html).find('form[zero-auto]');
	// $(zeroAutos).off('submit');
	// console.log(zeroAutos);
	for(var i = 0; i < zeroAutos.length; i++){

		var auto = zeroAutos[i];
		
		var formButton = $(auto).find('button');
		var icon = $(formButton).find('i');
		// console.log(icon.hasClass('fa'));

		if(icon.hasClass('fa-refresh')){
			icon.addClass('fa-spin');						
		} else {
			icon.removeClass();
			icon.addClass('fa fa-circle-o-notch fa-spin');
		}

		// console.log(auto);
		var timeout = $(auto).attr('zero-auto');
		setTimeout(function(){
			console.log(auto);
			// throw "";
			$(auto).trigger("submit");
		}, timeout * 1000)
	}

}

zeroOnChange = function(html){

	zeroForms = $(html).find('form[zero-submit-onchange');
	// console.log(zeroForms);
	for(var i=0; i < zeroForms.length; i++){
		var zeroForm = zeroForms[i];

		var inputs = $(zeroForm).find('input,select,textarea');
		for(var i2=0; i2 < inputs.length; i2++){

			var input = inputs[i2];
			// console.log(input);
			$(input).on("change", function(){
				// console.log('change');
				$(zeroForm).trigger("submit");
			})

		}

	}

}

loadTime = "";

zeroPreload = function(html){		
	var zeroPreloads = $(html).find('[zero-preload]');
	for(var i = 0; i < zeroPreloads.length; i++){
		var preload = $(zeroPreloads[i]);
		// var url = preload.attr('href');
		
		preload.on('mouseenter', function(){
			var d = new Date();
			loadTime = d.getTime();
			var attr = $(this).attr('preloaduuid');

			// For some browsers, `attr` is undefined; for others,
			// `attr` is false.  Check for both.
			if (typeof attr === typeof undefined || attr === false) {
				var uuid = generateUUID();
				console.log(uuid);					
				$(this).attr('preloaduuid', uuid);
				// document.cookie = "zeropreload=" + uuid;
				document.cookie = "zeropreload=" + uuid + "; expires=Thu, 18 Dec 2100 12:00:00 UTC; path=/";
				console.log(document.cookie);
				$.get($(this).attr('href')).done(function(){
					console.log(document.cookie);
					// document.cookie = "zeropreload=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/";						
				});					
			} 

		});

		preload.on('click', function(event){
			var d = new Date();
			endTime = d.getTime() - loadTime;
			console.log(endTime);
			// event.preventDefault();
			var attr = $(this).attr('preloaduuid');
			
			if (typeof attr !== typeof undefined && attr !== false) {					
				document.cookie = "zeropreload=" + attr + "; expires=Thu, 18 Dec 2100 12:00:00 UTC; path=/";	    
			}
		});		
	}
	console.log(zeroPreloads);

}

function generateUUID(){
    var d = new Date().getTime();
    if(window.performance && typeof window.performance.now === "function"){
        d += performance.now(); //use high-precision timer if available
    }
    var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (d + Math.random()*16)%16 | 0;
        d = Math.floor(d/16);
        return (c=='x' ? r : (r&0x3|0x8)).toString(16);
    });
    return uuid;
}

function zeroInit(){
	$(document).ready(function() {	
		zeroAjax($(document));	
		lastButtonClicked($(document));		
		zeroAuto($(document));	
		zeroOnChange($(document));	
		zeroAjaxAnchor($(document));
	});
}

var decodeBase64 = function(encodedString){
	var Base64={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",encode:function(e){var t="";var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t="";var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9+/=]/g,"");while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){e=e.replace(/rn/g,"n");var t="";for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t="";var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}

	// Define the string
	var encodedString = encodedString;					

	// Decode the String
	var decodedString = Base64.decode(encodedString);
	// console.log(decodedString); // Outputs: "Hello World!"
	return decodedString;
}

var setViewState = function(key, value){
					clientData.view_state[key] = value;
					console.log(clientData);
				}				

				var render = function(target){
					// console.log(clientData);
					var html = template(clientData);
					// $('body').prepend('<div id="zero-pre-render" style="display:none;">foo</div>');
					// $('#zero-pre-render').html(html);
					// // $('body').html(html);
					// 					
					//var targetHTML = result.substring(result.indexOf("<body>")+6,result.indexOf("</body>"));  					
										
					var animate = true;
					// var animate = false;
					if(!animate){
						// var targetHTML = html.substring(html.indexOf("<body>")+6,html.indexOf("</body>")); 
						$('body').html(html);	
						console.log('no animate');
					} else {
						var parsed = $.parseHTML(html, document, true);

						var newZeroAnimate = $(parsed).find('.zero-animate');
						// console.log(newZeroAnimate);
						var lastZeroAnimate = $('.zero-animate');

						if(newZeroAnimate.hasClass('zero-animate-off') && lastZeroAnimate.hasClass('zero-animate-on')){
							// console.log('show it');
							// newZeroAnimate.show();
							newZeroAnimate.css({ display: "block" });
						}

						if(newZeroAnimate.hasClass('zero-animate-on') && lastZeroAnimate.hasClass('zero-animate-off')){
							// console.log('hide it');
							newZeroAnimate.css({ display: "none" });
						}					 		
								
						if(typeof target !== 'undefined'){
							// console.log('target');
							var targetSource = $(parsed).find('#' + target);
							var targetDestination = $('#' + target);
							targetDestination.html(targetSource.html());
						} else {
							// console.log('body');
							$('body').html(parsed);						
						}

						// console.log(parsed);

						// $('body').html($('#zero-pre-render').html());
						// $('#zero-pre-render').html();

						$('.zero-animate.zero-animate-in.zero-animate-on').slideDown('slow', function(){
							// lastIsVisible = $('.zero-animate').is(':visible');							
						});
						$('.zero-animate.zero-animate-out.zero-animate-off').slideUp('slow', function(){
							// console.log('slide up');
							// lastIsVisible = $('.zero-animate').is(':visible');
						});						
					}


					zeroInit();	
				}