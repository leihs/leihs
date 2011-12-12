/*
 * Selection Actions
 *
 * This script sets up functionalities for selection based functionalities (hand over, take back, acknowledge, etc...)
 *
*/


var SelectionActions = new SelectionActions();

function SelectionActions() {
  
  this.setup = function() {
    this.deselectRadioButtons();
    this.setupMainSelection();
    this.setupGroupSelections();
    this.setupLineSelections();
    this.setupTimerangeUpdater();
    this.setupLinegroupHighlighting();
    this.setupDeleteSelection();
    this.setupEditSelection();
  }
  
  this.deselectRadioButtons = function() {
    $(".actiongroup input[type=radio]").attr("checked", false);
  }
  
  this.setupLinegroupHighlighting = function() {
    $("#add_item .date").change(function(){
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
   });
  }
  
  this.setupEditSelection = function() {
    $(".actiongroup #edit_selection").bind("click", function(event){
      // add all selected lines to the order data
      var lines_data = [];
      $(".line input:checked").each(function(i, input){
        lines_data.push($(this).closest(".line").tmplItem().data);
      });
      $("#order").data("selected_lines", lines_data);
    });
  }
  
  this.setupDeleteSelection = function() {
    $(".actiongroup #delete_selection").bind("click", function(event){
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
      SelectionActions.updateTimerange($(this).tmplItem().first_date, $(this).tmplItem().last_date);
    });

    $(".linegroup .button").live("click", function() {
      SelectionActions.updateTimerange($(this).closest(".linegroup").tmplItem().first_date, $(this).closest(".linegroup").tmplItem().last_date);
    });
  }
  
  this.setupMainSelection = function() {
    SelectionActions.updateSelectionCount();
    
    $(".actiongroup input[value='all']").change(function(){
      $(".lines>.line .select input[type='checkbox']:not(:checked)").attr("checked",true);
      $(".linegroup .dates input[type='checkbox']:not(:checked)").attr("checked",true);
      SelectionActions.updateSelectionCount();
      SelectionActions.checkIfEverythingIsSelected();
    });
  }
  
  this.setupGroupSelections = function() {
    $(".linegroup>.dates input[type='checkbox']").change(function(){
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
    $(".linegroup>.lines>.line .select input[type='checkbox']").change(function(){
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