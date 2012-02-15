/*
 * List
 *
 * This script sets up functionalities for lists
 *
*/

var List = new List();

function List() {
  
  this.per_page;
  this.current_page;
  this.total_entries;
  this.next_text = "Next";
  this.previous_text = "Previous";
  this.available_years;
  this.available_months;
  this.selected_year;
  this.selected_month;
  
  this.setup = function() {
    if($(".list .navigation .search input[type=query]").length) this.setupSearch();
    if($(".pagination_container").length) this.setupPagination();
    if($(".historical_search").length) this.setupHistoricalSearch();
  }
  
   this.setupHistoricalSearch = function() {
      var options = {};
      var available_months = List.available_months;
      
      if(available_months.length) options["available_months"] = available_months;
      options["available_years"] = List.available_years;
      options["selected_year"] = List.selected_year;
      options["selected_month"] = List.selected_month;
      options["callback"] = List.handleHistoricalSearchClick;
      
      $(".historical_search").historicalSearch(options);
    }
    
    this.handleHistoricalSearchClick = function(event) {
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
  
  this.setupPagination = function() {
    current_page = (List.current_page == 0) ? 0 : List.current_page-1;
    
    $(".pagination_container").pagination(List.total_entries, {
      items_per_page: List.per_page,
      callback: List.handlePaginationClick,
      current_page: current_page,
      num_display_entries: 7,
      num_edge_entries: 2,
      next_text: List.next_text,
      prev_text: List.previous_text
    });
    
    $(".pagination_container a").click(function(e){
      Dialog.add({
        content: $.tmpl("tmpl/dialog/loading"),
        dialogClass: ".loading"
      });
    });
  }
  
  this.handlePaginationClick = function (new_page_index, pagination_container) {
      var params = window.location.search;
      var page_param = "page="+parseInt(new_page_index+1);
      
      if(params.match(/page\=\d+/)) {
        params = params.replace(/page\=\d+/, page_param);
      } else {
        if (params.match(/^\?/)) {
          params = params+"&"+page_param;
        } else {
          params = "?"+page_param;      
        }
      }
      
      window.location = window.location.pathname + params;
      return false;
    }
  
  this.setupSearch = function() {
    var search = $(".list .navigation .search input[type=query]");
    
    if($(search).val() != $(search).data("start-text") && $(search).val() != "" && $(search).val() != undefined) $(search).addClass("active");
    
    if($(search).val() == "" || $(search).val() == undefined) $(search).val($(search).data("start_text"));
    
    $(search).focus(function(){
      if(!$(this).data("start_text")) $(this).data("start_text", $(this).val());
      if($(this).val() == $(this).data("start_text")) $(this).val("");
      $('.qtip').qtip('hide').qtip('disable');
    });
    
    $(search).blur(function(){
      if($(this).val() == "") {
        $(this).val($(this).data("start_text"));
        $(this).removeClass("active");
      } else {
        $(this).addClass("active");
      };
      $('.qtip').qtip('enable');
    });
    
    $(search).parents("form").submit(function() {
      $(this).find(".loading").show();
    });
  }
  
  this.remove_line = function(options) {
    element = options.element;
    color = options.color;
    callback = (options.callback != undefined) ? options.callback : function(){};
    if($(element).closest(".linegroup").length) {
      // element to delete is part of a linegroup
      $(element).css("background-color", color).fadeOut(400, function(){
        if($(this).closest(".linegroup").find(".lines .line").length == 1) {
          $(this).closest(".indent").next("hr").remove();
          $(this).closest(".indent").remove();
          if(typeof(SelectionActions) != "undefined") SelectionActions.updateSelectionCount();
        } else {
          $(this).remove();
          if(typeof(SelectionActions) != "undefined") SelectionActions.updateSelectionCount();
        }
        if(AcknowledgeOrder != undefined) {
          AcknowledgeOrder.checkApproveOrderAvailability();
        }
        // finaly callback
        callback.call(this);
      });
    } else if($(element).closest(".dialog").length) {
      // element to delete is part of a dialog
       $(element).css("background-color", color).fadeOut(400, function(){
        var lines_to_remove = [];         
        $(".line").each(function(i_line, line){
          if(JSON.stringify($(line).tmplItem().data) == JSON.stringify($(element).tmplItem().data)) {
            lines_to_remove.push(line);
          }              
        });
        
        $.each(lines_to_remove, function(i_line, line){
          if($(line).closest(".linegroup").length>0) {
            List.remove_line({"element": line, "color": color});
          } else {
            // just remove the line
            $(line).remove();
          }
        });
        
        if($(element).closest(".dialog").find(".list .line").length == 0) {
          // if it was the last line of the dialog close dialog as well
          $(".dialog").dialog("close");
        }
        
        // finaly callback
        callback.call(this);
      });
    } else {
      // its a default line (part of a list)
      var parent = $(element).parents(".list");
      $(element).css("background-color", color).fadeOut(400, function(){
        List.subtract(parent);
        $(this).remove();
        if(typeof(SelectionActions) != "undefined") SelectionActions.updateSelectionCount();
        
        // finaly callback
        callback.call(this);
      });
    }
  }
  
  this.update_reminder = function(element) {
    $(element).find(".reminder .grey").fadeOut(300, function(){
      $(this).siblings(".text").fadeIn(300);
    });
    $(element).find(".reminder .date").fadeOut(300, function(){
      var _text = "Today " + new Date().getHours() + ":" + new Date().getMinutes();
      $(this).html(_text).fadeIn(300);
    });
  }
  
  this.update_order = function(order) {
    $("#order").html("");
    $('#order').replaceWith($.tmpl("tmpl/order", order));
    
    // restore lines which were selected before re templating
    SelectionActions.restoreSelectedLines();
  }
  
  this.subtract = function(list) {
    // subtract badge
    var badge = $(list).prev(".inlinetabs").find(".tab:first .badge");
    var badge_amount = parseInt($(badge).html());
    $(badge).html(badge_amount-1);
    // subtract showmore toggle
    if($(list).find(".toggle").length > 0) {
      var showmore = $(list).find(".toggle");
      var showmore_html =  $(showmore).html();
      var showmore_val = showmore_html.replace(/<\/*.*?>/g, "");
      var showmore_val_num = parseInt(showmore_val.match(/\d*/g));
      var new_showmore_val = showmore_val.replace(showmore_val_num, showmore_val_num-1);
      var new_showmore_html = showmore_html.replace(showmore_val, new_showmore_val);
      $(showmore).html(new_showmore_html);
      // get new line from hidden container
      for (var i = 0; i < 1; i++) {
        var line = $(list).find(".hidden .line:first");
        $(list).find(".hidden").before(line);
      }
      // no more hidden lines to fetch
      if($(list).find(".hidden .line").length == 0){
        $(list).find(".toggle").remove();
        return 0;
      };
    }
  }
}