/*
 * Line Group
 *
 * This script sets up functionalities for LineGroups
 *
*/

$(document).ready(function(){
  LineGroup.setup();
});

var LineGroup = new LineGroup();

function LineGroup() {
  
  this.setup = function() {
    this.setupUpdatingAddItemTimeRange();
  }
  
  this.setupUpdatingAddItemTimeRange = function() {
    $(".linegroup, .linegroup .button").live("click", function() {
      var target = ($(this).hasClass(".button")) ? $(this).closest(".linegroup") : $(this);
      var start_date = target.tmplItem().data.start_date;
      var end_date = target.tmplItem().data.end_date;
      AddItem.updateTimerange(moment(start_date).toDate(), moment(end_date).toDate());
    });
  }
  
  this.highlightSelected = function(target_start_date, target_end_date) {
    target_start_date = moment(arguments[0]);
    target_end_date = moment(arguments[1]);
    
    $(".linegroup").each(function(){
      var start_date = moment($(this).tmplItem().data.start_date);
      var end_date = moment($(this).tmplItem().data.end_date);
      
      if(start_date.diff(target_start_date, "days") == 0 && end_date.diff(target_end_date, "days") == 0) {
        $(this).addClass("selected");
      } else {
        $(this).removeClass("selected");
      }
    }); 
  }
}