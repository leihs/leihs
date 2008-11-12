// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function checkbox_values(boxes){
	s = new Array();
	$$('body input.' + boxes).each(
		function(box){
			if(box.checked) s.push(box.value);
		}
	);
	return s;
}

//TODO write as generic
function change_href(a, checkbox_name, param_name, clear_arguments){
	clear_arguments = (clear_arguments == null) ? true : false;
	var cbv = checkbox_values(checkbox_name + '_check');
	
	// TODO prevent execution without selection
	//if(cbv.length == 0) {
		// window.event.stopPropagation();
	//}else{
		b = a.href.split('?');
		if (clear_arguments) {
			a.href = b[0] + '?' + param_name + 's=' + cbv;
		}
		else {
			a.href = b[0] + '?' + b[1] + '&' + param_name + 's=' + cbv; // TODO: Find place where it doesn't work. Needed for Take Back (Options...)
		}
		decoGreyboxLinks();
	//}


}

function change_href_with_clear(a, checkbox_name, param_name, clear_arguments)
{
	var cbv = checkbox_values(checkbox_name + '_check');
	
	// TODO prevent execution without selection
	//if(cbv.length == 0) {
		// window.event.stopPropagation();
	//}else{
		b = a.href.split('?');
		if (clear_arguments) {
			a.href = b[0] + '?' + param_name + 's=' + cbv;
		}
		else {
			a.href = b[0] + '?' + b[1] + '&' + param_name + 's=' + cbv; // TODO: Find place where it doesn't work. Needed for Take Back (Options...)
		}
		decoGreyboxLinks();
	//}
}


function mark_all(master, boxes, buttons){
	$$('body input.' + boxes).each(
		function(box){
			box.checked = master.checked
		}
	);
	
	toggle_buttons(boxes, buttons);
}

function toggle_buttons(boxes, buttons){
	s = checkbox_values(boxes);
	
	$$('body a.' + buttons).each(
		function(button){
			//old// button.style.visibility = (s.length > 0 ? 'visible' : 'hidden');
			if(s.length > 0){
				button.style.opacity = 1;
				button.style.filter = 'alpha(opacity=100)'; /* IE */
				// TODO 10** reset link // button.href="";
			}else{
				button.style.opacity = 0.4;
				button.style.filter = 'alpha(opacity=40)'; /* IE */
				// TODO 10** prevent link // button.href="javascript:return false;";
			}
		}
	);
}

function refresh_me() 
{ 
	window.location.reload();
}