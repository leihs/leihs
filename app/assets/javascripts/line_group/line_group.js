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
    $(".linegroup").live("click", function() {
      AddItem.updateTimerange(new Date($(this).tmplItem().data.start_date.replace(/-/g, "/")), new Date($(this).tmplItem().data.end_date.replace(/-/g, "/")));
    });

    $(".linegroup .button").live("click", function() {
      AddItem.updateTimerange(new Date($(this).closest(".linegroup").tmplItem().data.start_date.replace(/-/g, "/")), new Date($(this).closest(".linegroup").tmplItem().data.end_date.replace(/-/g, "/")));
    });
  }
  
  this.highlightSelected = function(target_start_date, target_end_date) {
    $(".linegroup").each(function(){
      var start_date = $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, new Date($(this).tmplItem().data.start_date));
      var end_date = $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, new Date($(this).tmplItem().data.end_date));
      if(start_date == target_start_date && end_date == target_end_date) {
        $(this).addClass("selected");
      } else {
        $(this).removeClass("selected");
      }
    }); 
  }
}