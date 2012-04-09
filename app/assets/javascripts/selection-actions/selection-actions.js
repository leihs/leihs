/*
 * Selection Actions
 *
 * This script sets up functionalities for selection based functionalities
 *
*/

var SelectionActions = new SelectionActions();

function SelectionActions() {
  
  this.selected_lines;
  this.target;
  
  this.setup = function(_target) {
    this.target = _target;
    this.deselectRadioButtons();
    this.setupMainSelection();
    this.setupGroupSelections();
    this.setupLineSelections();
    LineGroup.highlightSelected($("#add_item #add_start_date").data("date"), $("#add_item #add_end_date").data("date"));
  }
  
  this.deselectRadioButtons = function() {
    $("#selection_actions input[type=radio]").attr("checked", false);
  }
  
  this.storeSelectedLines = function() {
    // add all selected lines to the order data
    var lines_data = [];
    var min_start_date;
    var max_end_date;
    $(".innercontent .line input:checked").each(function(i, input){
      var line = $(this).closest(".line");
      // set line data
      lines_data.push($(line).tmplItem().data);
      // set start date
      if(min_start_date == undefined){
        min_start_date = moment($(line).tmplItem().data.start_date).sod().toDate();
      } else if (moment($(line).tmplItem().data.start_date).sod().toDate().getTime() < min_start_date.getTime()) {
        min_start_date = moment($(line).tmplItem().data.start_date).sod().toDate();
      }
      // set end date
      if(max_end_date == undefined){
        max_end_date = moment($(line).tmplItem().data.end_date).sod().toDate();
      } else if(moment($(line).tmplItem().data.end_date).sod().toDate().getTime() > max_end_date.getTime()) {
        max_end_date = moment($(line).tmplItem().data.end_date).sod().toDate();
      }
    });
    
    SelectionActions.selected_lines = lines_data;
    SelectionActions.target.tmplItem().data.selected_lines = lines_data;
    SelectionActions.target.tmplItem().data.selected_range = {start_date: min_start_date, end_date: max_end_date};
  }
  
  this.restoreSelectedLines = function() {
    var selected_lines = this.selected_lines;
        
    // select all selected lines again
    SelectionActions.target.find(".line").each(function(i_line,line){
      $.each(selected_lines, function(i_selected, selected_line){
        if($(line).tmplItem().data.id == selected_line.id) {
          $(line).find("input[type=checkbox]").attr("checked",true);
          $(line).find("input[type=checkbox]").change();
        }
      });
    });
  }
  
  this.setupMainSelection = function() {
    SelectionActions.updateSelectionCount();
    
    $("#selection_actions input[value='all']").live("change", function(){
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
      $("#selection_actions input[value='all']").attr("checked", true);
      SelectionActions.disableSelectionActionRange();
    } else {
      if($(".lines>.line .select input[type='checkbox']:checked").length == 0) {
        SelectionActions.disableSelectionActionRange();
        $("#selection_actions input[value='selection']").attr("checked", false);
      } else {
        SelectionActions.enableSelectionActionRange();
        $("#selection_actions input[value='selection']").attr("checked", true);
      }
    }
  }
  
  this.updateSelectionCount = function() {
    var _newCount = "("+ $(".lines>.line .select input[type='checkbox']:checked").length +")";
    $("#selection_actions .selection .count").html(_newCount);
      
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