/*
 * Acknowledge
 *
 * This script provides functionalities for the acknowledge order process
 *
*/

var AcknowledgeOrder = new AcknowledgeOrder();
  
function AcknowledgeOrder() {

  this.setup = function () {
    this.setupPurpose();
    this.checkApproveOrderAvailability();
  }
  
  this.update_order = function(order) {
    // reset the order template with the new data
    $("#order").html("");
    $('#order').replaceWith($.tmpl("tmpl/order", order));
    
    // update selection target
    SelectionActions.set_target($('#order'));
    
    // update the subtitle numbers
    var subtitle_text = $("#acknowledge .subtitle").html();
    subtitle_text.replace(/^\d+/, order.quantity);
    subtitle_text.replace(/\s\d+/, " "+new MaxRange(order.lines).value);
    $("#acknowledge .subtitle").html(subtitle_text);
    
    // restore lines which were selected before re templating
    SelectionActions.restoreSelectedLines();
  }
  
  this.checkApproveOrderAvailability = function () {
    if ($("#order").find(".lines").length == 0) {
      Buttons.disable($("#approve.multibutton"));
    } else {
      Buttons.enable($("#approve.multibutton"));
    }      
  }
  
  this.setupPurpose = function () {
    if($(".indent.purpose").height() > 70){
      $(".indent.purpose").addClass("collapsed");
      $(".indent.purpose").after("<div class='showmore'></div>");
    }
    
    $(".indent.purpose.collapsed").live("click", function(){
      $(this).removeClass("collapsed");
      $(this).addClass("expanded");
    });
    
    $(".indent.purpose.expanded").live("click", function(){
      $(this).removeClass("expanded");
      $(this).addClass("collapsed");
    });
  }
}