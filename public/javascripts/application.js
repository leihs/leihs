// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/*	
// Ajax Pagination :: http://wiki.github.com/mislav/will_paginate/ajax-pagination //
// adapted by sellittf //
document.observe("dom:loaded", function() {
  // the element in which we will observe all clicks and capture
  // ones originating from pagination links
  var container = $(document.body)
  if (container) {
    container.observe('click', function(e) {
      var el = e.element()
      if (el.match('.pagination a')) {
        new Ajax.Request(el.href, { method: 'get' , evalJS: true
        							// TODO ajax history
									//onSuccess: function(request) {
										// this will happen automatically: eval(request.responseText);
										//dhtmlHistory.add(request.request.url, "location.assign('" + request.request.url + "');");
									//}
		});
        e.stop();
      }
    })
  }

//	Ajax.Responders.register({
//	  onComplete: function(request) {
	  	// Solution 1: just evaluating previous ajax request response
		// dhtmlHistory.add(request.url, request.transport.responseText);
		
		// Solution 2: re-executing the ajax request getting new response
//        dhtmlHistory.add(request.url, "new Ajax.Request('" + request.url + "', " + Object.toJSON(request.options) + ");");
//	  }
//	});

});
*/	

// TODO switch to jQuery
jQuery(document).ready(function($){
	// Ajax Pagination with jQuery
	$(".pagination a").live("click", function() {
		var target = $(this);
		$.ajax({
			url: target.attr("href"),
			dataType: "script",
			beforeSend: function(){
				target.replaceWith("<img src='/images/spinner.gif'>");
			}
			/*
		    success: function(response){
				//old// $("#list_table").html(response);
				$("#list_table").replaceWith(response);
				//TODO// dhtmlHistory.add(request.request.url, "new Ajax.Request('" + request.request.url + "', { method: 'get', onSuccess: function(request) { $('list_table').update(request.responseText); } });");
		    }
		    */
		});
		return false;
	});
});

//////// Really Simple History //////////
/*
window.dhtmlHistory.create({
  toJSON: function(o) {
    return Object.toJSON(o);
  },
  fromJSON: function(s) {
    return s.evalJSON();
  }
});

var pageListener = function(newLocation, historyData) {
  eval(historyData);
};

window.onload = function() {
  dhtmlHistory.initialize();
  dhtmlHistory.addListener(pageListener);
}
*/
/////////////////////////////////////////////////////////

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

function date_select_to_param_string(date){
	var d = $(date).value.split('.');
	return '' + d[2] + '-' + d[1] + '-' + d[0];
}

function change_href_with_dates(a, start_date, end_date){
	sd = date_select_to_param_string(start_date);
	ed = date_select_to_param_string(end_date);
	b = a.href.split('?');
	a.href = b[0] + '?start_date=' + sd + '&end_date=' + ed;
	decoGreyboxLinks();
}

/////////////////////////////////////////////////////////

// TODO prevent field for unchecked lines to be sent
function input_values(inputs){
	s = "";
	$$('body input.' + inputs).each(
		function(input){
			// OPTIMIZE "contract_line" is hardcoded
			// FIXME input.value is wrong!!! // if($('contract_line_check_' + input.value).checked)
			s += '&' + input.name + '=' + input.value;
		}
	);
	return s;
}

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

function show_date(d,f){
	var r = "";

	if (f == true) // long format
		{
			var weekday=new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")
			var monthname=new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")
			r += d.getDate() + ". ";
			r += monthname[d.getMonth()] + " ";
			r += d.getFullYear() + ", ";
			r += weekday[d.getDay()];
		}
	else
		{
			r += d.getDate() + ".";
			r += d.getMonth()+1 + ".";
			r += d.getFullYear();
		}
	
	return r;
}

function replace_with_target(element) {
	// OPTIMIZE use UJS rails.js
	var target = jQuery(element);
	jQuery.ajax({
		url: target.attr("href"),
		beforeSend: function(){
			target.html("Loading...");
		},
		success: function(response){
			target.parent().removeClass("buttons"); /* not a button any more */
			target.replaceWith(response);
		}
	});
	return false;
}


/////////////////////////////////////////////////////////

// Handover handling for a user's contract


// returns the id of the line that an input element refers to
function line_id(input_id) {
  return (input_id.replace("line_item_inventory_code_",""));
}


var line_items = {};

function on_item_code_input_focus(element, item_inventory_code) {
  var l_id = line_id(element.id);

  if( element.value != item_inventory_code &&
      element.value != line_items[l_id]       ) {
    line_items[l_id] = element.value;

    var url = '/backend/inventory_pools/' + current_inventory_pool_id +
	      '/users/' + current_user_id +
	      '/hand_over/change_line?contract_line_id=' + l_id;

    var parameters = 'code=' + element.value + 
	             '&authenticity_token=' + 
		     encodeURIComponent($$('input[name=authenticity_token]')[0].value);

    new Ajax.Request( url,
                      { asynchronous:true,
                        evalScripts: true,
                        parameters:  parameters
                      });
  }
}

var autocompleters = {};

function do_autocomplete(element) {
  var l_id = line_id(element.id);
  // only create a new autocompleter if there isn't one yet
  if(element.value == '' && ! autocompleters[l_id]) {
    autocompleters[l_id] =
      new Autocompleter.Local( element.id,
                               element.id + "_list",
                               styled_inventory_codes[l_id],
                               {fullSearch: true} );
  }
  if(autocompleters[l_id]) autocompleters[l_id].activate();
}
