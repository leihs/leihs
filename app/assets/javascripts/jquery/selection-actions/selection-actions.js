/*
 * Selection Actions
 *
 * This script sets up functionalities for selection based functionalities (hand over, take back, acknowledge, etc...)
 *
*/

var SelectionActions = new SelectionActions();

function SelectionActions() {
  
  this.setup = function() {
    this.setupMainSelection();
    this.setupGroupSelections();
    this.setupLineSelections();
    this.setupTimerangeUpdater();
  }
  
  this.setupTimerangeUpdater = function() {
    $(".linegroup").live("click", function() {
      SelectionActions.updateTimerange($(this).tmplItem().first_date, $(this).tmplItem().last_date);
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
    if($("#add_item #start_date").val() != $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, start_date)) {
      $("#add_item #start_date").val($.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, start_date));
      $("#add_item #start_date").css("color", "#515151").css("border-color", "#a2a19c").css("box-shadow", "0 0 6px #DDD").css("-moz-box-shadow", "0 0 6px #DDD").css("-webkit-box-shadow", "0 0 6px #DDD");
      $("#add_item #start_date").stop().animate({
        color: "#717171",
        "border-color": "#cccccc",
      }, 800, function() {
        $(this).css("box-shadow", "0 0 0 #FFF").css("-moz-box-shadow", "0 0 0 #FFF").css("-webkit-box-shadow", "0 0 0 #FFF")
      });
    }
    if($("#add_item #end_date").val() != $.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, end_date)) {
      $("#add_item #end_date").val($.datepicker.formatDate(i18n.selected.datepicker_backend.dateFormat, end_date));
      $("#add_item #end_date").css("color", "#515151").css("border-color", "#a2a19c").css("box-shadow", "0 0 6px #DDD").css("-moz-box-shadow", "0 0 6px #DDD").css("-webkit-box-shadow", "0 0 6px #DDD");
      $("#add_item #end_date").stop().animate({
        color: "#717171",
        "border-color": "#cccccc",
      }, 800, function() {
        $(this).css("box-shadow", "0 0 0 #FFF").css("-moz-box-shadow", "0 0 0 #FFF").css("-webkit-box-shadow", "0 0 0 #FFF")
      });
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