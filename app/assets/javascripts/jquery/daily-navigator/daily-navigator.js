/*
 * DailyNavigator
 *
 * This script setups the daily navigator, 
 * used to navigate to different dates inside 
 * of the daily view
 *
 * @name DailyNavigator
*/

$(document).ready(function(){
  if($("#daily .content_navigation")) DailyNavigator.setup();
});

var DailyNavigator = new DailyNavigator();

function DailyNavigator() {
  
  this.is_today = true;
  this.current_date = new Date();
  this.oneDay = 86400000; // in milliseconds
  
  this.setup = function() {
    this.setupToday();
    this.setupDisabled();
    this.setupNavigation();
    this.setupDatepicker();
  }
  
  this.setupToday = function() {
    var params = window.location.search;
    
    // check if is_today is selected
    if(params.match(/date=/)) {
      var date_param = params.match(/date=\d{4}-\d{1,2}-\d{1,2}/)[0];
      date_param = date_param.replace("date=", "").replace(/\-/g, "/");
      var date = new Date(date_param);
      var is_today = new Date();
      is_today.setHours(0);
      is_today.setMinutes(0);
      is_today.setSeconds(0);
      is_today.setMilliseconds(0);
      if(date.getTime() == is_today.getTime()) {
        DailyNavigator.is_today = true;
      } else {
        DailyNavigator.is_today = false;
        DailyNavigator.current_date = date;
      }
    } else {
      DailyNavigator.is_today = true;
    }
  }
  
  this.setupDisabled = function() {
    // disabled not needed buttons
    if(DailyNavigator.is_today) {
      $("#daily .content_navigation .today").attr("disabled", true);
      $("#daily .content_navigation .day.back").attr("disabled", true);
    }
  }
  
  this.setupNavigation = function() {
    $("#daily .content_navigation .day.forward").bind("click", function() {
      DailyNavigator.gotoDate(new Date(DailyNavigator.current_date.getTime()+DailyNavigator.oneDay));      
    });
        
    // bind only if not today
    if(!DailyNavigator.is_today) {
      $("#daily .content_navigation .day.back").bind("click", function() {
        DailyNavigator.gotoDate(new Date(DailyNavigator.current_date.getTime()-DailyNavigator.oneDay));      
      });
    }
  }
  
  this.setupDatepicker = function() {
    $.datepicker.setDefaults(i18n.selected.datepicker_backend);
    
    $('#daily .content_navigation #datepicker').datepicker({
      minDate: new Date(),
      defaultDate: DailyNavigator.current_date,
      onClose: function(dateText, inst) {
        if(typeof(dateText) == "string" && dateText.search(/{.*?}/) == -1 && dateText != ""){
          date = $.datepicker.parseDate(i18n.selected.datepicker_backend.dateFormat, dateText);
          DailyNavigator.gotoDate(date);
        }
      }
    });
    
    $('#daily .content_navigation .datepicker').bind("click", function() {
      $('#daily .content_navigation #datepicker').datepicker("show");
    });
  }
  
  this.gotoDate = function(date) {
    var params = window.location.search;
    var date_param = ""+date.getFullYear()+"-"+(date.getMonth()+1)+"-"+date.getDate();
    var new_params;
    
    if(params.match(/date=/)) { // matched date param inside current params
      new_params = params.replace(/date=\d{4}-\d{1,2}-\d{1,2}/, "date="+date_param);        
    } else if (params == "") { // current params are empty
      new_params = "?date="+date_param;
    } else { // there are current params but no date is setted
      new_params = params+"&date="+date_param;
    }
    
    window.location = "http://"+location.host+location.pathname+new_params;
  }
}