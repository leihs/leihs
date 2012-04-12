/*
 * Historical Search
 *
 * This script sets up functionalities for lists using Historical Search
 *
*/

var HistoricalSearch = new HistoricalSearch();

function HistoricalSearch() {
  
  this.available_years;
  this.available_months;
  this.selected_year;
  this.selected_month;
  
  this.setup = function() {
    var options = {};
    var available_months = HistoricalSearch.available_months;
      
    if(available_months.length) options["available_months"] = available_months;
    options["available_years"] = HistoricalSearch.available_years;
    options["selected_year"] = HistoricalSearch.selected_year;
    options["selected_month"] = HistoricalSearch.selected_month;
    options["callback"] = HistoricalSearch.on_click;
    
    $(".historical_search").historicalSearch(options);
  }
  
  this.on_click = function(event) {
    event.preventDefault();
    var target = event.currentTarget;
    var params = window.location.search;
    
    // clean page when new date is selected
    params = params.replace(/\?*?\&*page\=\d+/, "");
    
    if($(target).hasClass("back")) {
      params = params.replace(/\?*?&*?year\=\d+/, "");
      params = params.replace(/\?*?&*?month\=\d+/, "");
    } else if($(target).data("year")) {
      if (params.match(/year\=/)) {
        params = params.replace(/year\=\d*/, "year="+$(target).data("year"));
      } else {
        if (params.match(/^\?/)) {
          params = params+"&year="+$(target).data("year");
        } else {
          params = "?year="+$(target).data("year");     
        }       
      }
    } else if($(target).data("month")) {
      if (params.match(/month\=/)) {
        params = params.replace(/month\=\d*/, "month="+$(target).data("month"));
      } else if (params.match(/^\?/)) {
        params = params+"&month="+$(target).data("month");
      } else {
        params = "?month="+$(target).data("month");      
      }
    }
    
    if(params == "?&") params ="";
    
    window.location = window.location.pathname + params;
    return false;
  }
}