/*
 * Selection Actions
 *
 * This script sets up functionalities for selection based functionalities (hand over, take back, acknowledge, etc...)
 *
*/


var SelectionActions = new SelectionActions();

function SelectionActions() {
  
  this.selected_lines;
  
  this.setup = function() {
    this.deselectRadioButtons();
    this.setupMainSelection();
    this.setupGroupSelections();
    this.setupLineSelections();
    this.setupTimerangeUpdater();
    this.setupLinegroupHighlighting();
    this.setupDeleteSelection();
    this.setupEditSelection();
    this.checkIfLinegroupIsSelected();
  }
  
  this.deselectRadioButtons = function() {
    $(".actiongroup input[type=radio]").attr("checked", false);
  }
  
  this.setupLinegroupHighlighting = function() {
    $("#add_item .date").live("change", function(){
      SelectionActions.checkIfLinegroupIsSelected();
   });
  }
  
  this.checkIfLinegroupIsSelected = function() {
    // highlight selected group of lines
    $(".linegroup").each(function(){
      var start_date = $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, new Date($(this).tmplItem().data.start_date));
      var end_date = $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, new Date($(this).tmplItem().data.end_date));
      if(start_date == $("#add_item #add_start_date").val() && end_date == $("#add_item #add_end_date").val()) {
        $(this).addClass("selected");
      } else {
        $(this).removeClass("selected");
      }
    }); 
  }
  
  this.setupEditSelection = function() {
    $(".actiongroup #edit_selection").live("click", function(event){
      
    });
  }
  
  this.storeSelectedLines = function() {
    // add all selected lines to the order data
    var lines_data = [];
    var min_start_date;
    var max_end_date;
    $(".line input:checked").each(function(i, input){
      var line = $(this).closest(".line");
      // set line data
      lines_data.push($(line).tmplItem().data);
      // set start date
      if(min_start_date == undefined){
        min_start_date = new Date($(line).tmplItem().data.start_date.replace(/-/g, "/"));
      } else if(new Date(line.tmplItem().data.start_date.replace(/-/g, "/")).getTime() < min_start_date.getTime()) {
        min_start_date = new Date($(line).tmplItem().data.start_date.replace(/-/g, "/"));
      }
      // set end date
      if(max_end_date == undefined){
        max_end_date = new Date($(line).tmplItem().data.end_date.replace(/-/g, "/"));
      } else if(new Date(line.tmplItem().data.end_date.replace(/-/g, "/")).getTime() > max_end_date.getTime()) {
        max_end_date = new Date($(line).tmplItem().data.end_date.replace(/-/g, "/"));
      }
    });
    
    // add data to #order .container template item data
    $("#order .container").tmplItem().data.selected_lines = SelectionActions.selected_lines = lines_data;
    $("#order .container").tmplItem().data.selected_range = {start_date: min_start_date, end_date: max_end_date};
  }
  
  this.restoreSelectedLines = function() {
    var selected_lines = this.selected_lines;
        
    // select all selected lines again
    $("#order .line").each(function(i_line,line){
      $.each(selected_lines, function(i_selected, selected_line){
        if($(line).tmplItem().data.id == selected_line.id) {
          $(line).find("input[type=checkbox]").attr("checked",true);
          $(line).find("input[type=checkbox]").change();
        }
      });
    });
  }
  
  this.setupDeleteSelection = function() {
    $(".actiongroup #delete_selection").live("click", function(event){
      // add all selected lines to delete selections buttons data + params for the remote action
      var lines = [];
      var action = $(this).attr("href");
      action = action.replace(/\?.*?$/,"");
      action += "?"
      $(".line input:checked").each(function(i, input){
        var line = $(this).closest(".line");
        lines.push($(line));
        if(i==0) {
          action += "delete_line_ids[]=" + line.tmplItem().data.id;          
        } else {
          action += "&delete_line_ids[]=" + line.tmplItem().data.id;
        }
      });
      $(this).data("lines", lines);
      $(this).attr("href", action);
    });
  }
  
  this.setupTimerangeUpdater = function() {
    $(".linegroup").live("click", function() {
      SelectionActions.updateTimerange(new Date($(this).tmplItem().data.start_date.replace(/-/g, "/")), new Date($(this).tmplItem().data.end_date.replace(/-/g, "/")));
    });

    $(".linegroup .button").live("click", function() {
      SelectionActions.updateTimerange(new Date($(this).closest(".linegroup").tmplItem().data.start_date.replace(/-/g, "/")), new Date($(this).closest(".linegroup").tmplItem().data.end_date.replace(/-/g, "/")));
    });
  }
  
  this.setupMainSelection = function() {
    SelectionActions.updateSelectionCount();
    
    $(".actiongroup input[value='all']").live("change", function(){
      $(".lines>.line .select input[type='checkbox']:not(:checked)").attr("checked",true);
      $(".linegroup .dates input[type='checkbox']:not(:checked)").attr("checked",true);
      SelectionActions.updateSelectionCount();
      SelectionActions.checkIfEverythingIsSelected();
    });
  }
  
  this.setupGroupSelections = function() {
    $(".linegroup>.dates input[type='checkbox']").live("change", function(){
      if($(this).attr('checked')) {
        $(this).closest(".linegroup").find(".select input[type='checkbox']").attr('checked', true);
      } else {
        $(this).closest(".linegroup").find(".select input[type='checkbox']").attr('checked', false);
      }
      SelectionActions.updateSelectionCount();
      SelectionActions.checkIfEverythingIsSelected();
    });
  }
  
  this.setupLineSelections = function() {
    $(".linegroup>.lines>.line .select input[type='checkbox']").live("change", function(){
      if($(this).attr('checked')) {
        SelectionActions.checkIfGroupIsComplete($(this).closest(".linegroup"));
      } else {
        $(this).closest(".linegroup").find(".dates input[type='checkbox']").attr('checked', false);  
      }
      SelectionActions.updateSelectionCount();
      SelectionActions.checkIfEverythingIsSelected();
    });
  }
  
  this.checkIfGroupIsComplete = function(group) {
    if($(group).find(".lines>.line .select input[type='checkbox']:not(:checked)").length == 0) {
      $(group).find(".dates input[type='checkbox']").attr('checked', true);
    }
  }
  
  this.checkIfEverythingIsSelected = function() {
    if($(".lines>.line .select input[type='checkbox']:not(:checked)").length == 0) {
      $(".actiongroup input[value='all']").attr("checked", true);
      SelectionActions.disableSelectionActionRange();
    } else {
      if($(".lines>.line .select input[type='checkbox']:checked").length == 0) {
        SelectionActions.disableSelectionActionRange();
        $(".actiongroup input[value='selection']").attr("checked", false);
      } else {
        SelectionActions.enableSelectionActionRange();
        $(".actiongroup input[value='selection']").attr("checked", true);
      }
    }
  }
  
  this.updateSelectionCount = function() {
    var _newCount = "("+ $(".lines>.line .select input[type='checkbox']:checked").length +")";
    $(".actiongroup input#selection_range_selection").siblings(".count").html(_newCount);
      
    if($(".lines>.line .select input[type='checkbox']:checked").length) {
      SelectionActions.enableSelectionActionButton();
      SelectionActions.enableSelectionActionRange();
    } else {
      SelectionActions.disableSelectionActionButton();
      SelectionActions.disableSelectionActionRange();
    }
    
    // store changes
    SelectionActions.storeSelectedLines();
  }
  
  this.updateTimerange = function(start_date, end_date) {
    // show new selected start date
    if($("#add_item #add_start_date").val() != $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, start_date)) {
      $("#add_item #add_start_date").val($.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, start_date)).change();
    }
    // show new selected end date
    if($("#add_item #add_end_date").val() != $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, end_date)) {
      $("#add_item #add_end_date").val($.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, end_date)).change();
      $("#add_item #add_end_date").datepicker('setDate', $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, end_date));
    }
  }
  
  this.disableSelectionActionButton = function() {
    $("#selection_actions .multibutton").attr("disabled", true);
    $("#selection_actions .multibutton .button").attr("disabled", true);
  }
  
  this.enableSelectionActionButton = function() {
    $("#selection_actions .multibutton").attr("disabled", false);
    $("#selection_actions .multibutton .button").attr("disabled", false);
  }
  
  this.disableSelectionActionRange = function() {
    $("#selection_actions .selection #selection_range_selection").attr("disabled", true);
    $("#selection_actions .selection #selection_range_selection").parent().attr("disabled", true);
  }
  
  this.enableSelectionActionRange = function() {
    $("#selection_actions .selection #selection_range_selection").attr("disabled", false);
    $("#selection_actions .selection #selection_range_selection").parent().attr("disabled", false);
  }
}