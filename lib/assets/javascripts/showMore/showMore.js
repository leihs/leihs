/**
 * ShowMore - jQuery plugin
 * @version: 1.0 (2011/10/19)
 * @author Sebastian Pape
 * 
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 * 
 * @param min: 5                    // The minimum visible items
 * @param acc: 50                   // acceleration of the viewport animating
 * @param more: "%d more"           // The text on the more trigger (%d is replaced by amount of hidden items) 
 * @param less: "less"              // The text of the trigger when showmore is expanded
 * @param offset: {top: 0}          // Offset for the viewport animation
 * 
 * ***** EXAMPLE ****
 * 
 * $('#container').showMore({ params });  
 * 
 * ******************
 * 
**/

(function($) {
	
	var sM_instances = [];
  var sM_options = {};
  var sM_containers = {};
	
	$.fn.showMore = function(given_sM_options){
    
    setup_items = function(element) {
      
      $(element).attr("id", "showMore"+sM_instances.length);
      sM_options[element.id] = $.extend({}, $.fn.showMore.defaults, given_sM_options);
      sM_instances.push($(element));
      
      var hidden = $("<div class='hidden' style='display: none;'></div>");
      
      $(element).children().each(function(index, item){
        if(index < sM_options[element.id].min) {
          $(element).append(item);
        } else {
          $(hidden).append(item);
        }
      });
      
      $(element).append(hidden);
    }
    
    setup_toggle = function(element) {
      
      var toggle = $(element).children(":first").clone();
      var new_text = sM_options[element.id].more.replace(/%d/g, $(element).find(".hidden").children().length);
      new_text = new_text.replace(/%1\+d/g, $(element).find(".hidden").children().length+1);
      toggle.addClass("toggle show_more").data("is_open", false).html(new_text);
      
      if ($(element).find(".hidden").children().length) {
        $(element).append(toggle);  
        $(element).addClass("showMore").addClass("closed");
      
        toggle.click(function(){
          $(this).data("is_open", !$(this).data("is_open"));
          
          if($(this).data("is_open")) {
            show_more(element, toggle);
          } else {
            show_less(element, toggle);
          }
        });
      }
    }
    
    show_more = function(element, toggle) {
      $(element).find(".hidden").show();
      $(element).closest(".showMore").addClass("open").removeClass("closed");
      toggle.removeClass("show_more").addClass("show_less").html(sM_options[element.id].less);
    }
    
    show_less = function(element, toggle) {
      $(element).find(".hidden").hide();
      $(element).closest(".showMore").addClass("closed").removeClass("open");
      var new_text = sM_options[element.id].more.replace(/%d/g, $(element).find(".hidden").children().length);
      new_text = new_text.replace(/%1\+d/g, $(element).find(".hidden").children().length+1);
      toggle.removeClass("show_less").addClass("show_more").html(new_text);
    }
    
    this.each(function() {
      setup_items(this);
      setup_toggle(this);
    });
  };

	$.fn.showMore.defaults = {	
    min: 5,
    acc: 50,
    more: "%d more",
    less: "show less",
    offset: {
      top: 0
    }
	};
	
})(jQuery);