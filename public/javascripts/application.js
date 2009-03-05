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

/////////////////////////////////////////////////////////

// TODO 2702** optimize
function input_values(inputs){
	s = "";
	$$('body input.' + inputs).each(
		function(input){
			s += '&' + input.name + '=' + input.value;
		}
	);
	return s;
}

// TODO 2702** optimize
function change_href_input(a, input_name){
	var s = input_values(input_name);
	
	a.href += s;
	decoGreyboxLinks();
}

/////////////////////////////////////////////////////////


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

function show_date(d){
	var weekday=new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")
	var monthname=new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
	var r = "";
	r += weekday[d.getDay()] + "<br/>";
	r += d.getDate() + ". ";
	r += monthname[d.getMonth()] + " ";
	r += d.getFullYear();
	return r;
}
