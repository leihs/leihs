/**
 * Historical-Search - jQuery plugin
 * @version: 1.0 (2011/11/08)
 * @author Sebastian Pape
 * 
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 * 
 * @param callback: theCallBackFunction          // The function which will be called on click on an item
 * @param selected_year: 2009                    // The selected year as integer
 * @param selected_month: 1                      // The selected month as integer
 * @param month_names: ["Jan", "Feb" ...]        // The month names in array
 * @param back_text: "Return to years"           // Title for go back to years link
 * @param available_months: [1..12]              // Monthnumbers available
 * 
 * ***** EXAMPLE ****
 * 
 * $('#container').historicalSearch({ options });  
 * 
 * ******************
 * 
**/
 (function($){
   
  var hs_instances = [];
  var hs_options = {};
  var hs_containers = {};
  var hs_elements = {};
	
	$.fn.historicalSearch = function(opts){
	  
	  render_elements = function(element) {
	    var container = $("<div class='hs_container' id='historicalSearch"+hs_instances.length+"' />")
	    $(element).append(container);
      hs_options[element.id] = $.extend({}, $.fn.historicalSearch.defaults, opts);
      container = $(element).find(".hs_container");
      hs_instances.push(container);
      
      //// compute elements depending on selection
      if(hs_options[element.id].selected_year) {
        // year is selected
        var back_item = $("<a href='#' class='back' title='"+hs_options[element.id].back_text+"'>&laquo;</a>");
        $(container).append(back_item);
        $(container).append("<span class='current'>"+hs_options[element.id].selected_year+"</span>");
        if(hs_options[element.id].available_years.length) {
          for (month = 1; month <= 12; month++) {
            if($.inArray(parseInt(month), hs_options[element.id].available_months) != -1) {
              var _class = (hs_options[element.id].selected_month == month) ? "current" : "";
              var _item = $("<a href='#' class='"+_class+"'>"+hs_options[element.id].month_names[month-1]+"</a>");
                  _item.data("month", month);
              $(container).append(_item);
            }
          }
        } else if(hs_options[element.id].selected_month) {
          var _item = $("<a href='#' class='current'>"+hs_options[element.id].month_names[hs_options[element.id].selected_month-1]+"</a>");
          $(container).append(_item);
        }
      } else {
        // nothing is selected
        var years = hs_options[element.id].available_years;
        for (i in years) {
          var _item = $("<a href='#'>"+years[i]+"</a>");
              _item.data("year", years[i]);
          $(container).append(_item);
        }
      }
      
      $(container).find("a").click(hs_options[element.id].callback);
    }
	  
	  this.each(function() {
      render_elements(this);
    });
	}
	
	$.fn.historicalSearch.defaults = { 
    callback: function() {return 0;},
    selected_year: undefined,
    selected_month: undefined,
    month_names: ["Jan", "Feb", "Mar", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    back_text: "Return to years",
    available_months: [1,2,3,4,5,6,7,8,9,10,11,12],
    available_years: []
  };
})(jQuery);
