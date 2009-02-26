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


function change_href(a, checkbox_name, param_name){
	var cbv = checkbox_values(checkbox_name + '_check');
	
	b = a.href.split('?');
	a.href = b[0] + '?' + param_name + 's=' + cbv;
	decoGreyboxLinks();
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
			if(s.length > 0){
				button.removeClassName('ghosted');
				button.onclick = function(){ }
			}else{
				button.addClassName('ghosted');
				button.onclick = function(){ return false; }
			}
		}
	);
}

function refresh_me() 
{ 
	window.location.reload();
}