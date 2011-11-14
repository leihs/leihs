/*
 * Buttons
 *
 * This script setups interactivity on buttons (e.g. loading indicator etc)
 *
*/

$(document).ready(function(){
  
  Buttons.setup();
});

var Buttons = new Buttons();

function Buttons() {
  
  this.loadingImg = $("<img src='/assets/loading.gif' class='loading'/>");
  
  this.setup = function() {
    this.setupAjaxListener();
    this.setupDialogListener();
    this.setupMultibutton();
  }
  
  this.setupMultibutton = function() {
    $(".multibutton[disabled!=disabled] .alternatives").live("mouseenter", function(){
      $(this).closest(".multibutton").addClass("open");
    });
    
    $(".multibutton").live("mouseleave", function(){
      $(this).closest(".multibutton").removeClass("open");
    });
    
    $(".multibutton[disabled=disabled] .button").live("click mousedown", function(event){
      event.preventDefault();
      return false;
    });
  }
  
  this.setupDialogListener = function() {
    $(".button.close_dialog[disabled!=disabled]").live("click", Buttons.closeDialog);
    $(".button.open_dialog[disabled!=disabled]").live("click", Buttons.openDialog);
  }
  
  this.closeDialog = function(event) {
    var _this = $(this);
    $(_this).parents(".dialog").dialog("close");
    event.preventDefault();
    return false;
  }
  
  this.openDialog = function(event) {
    var _this = $(event.currentTarget);
    Dialog.add({
      trigger: _this,
      content: $.tmpl(_this.data("rel"), eval(_this.data("ref_for_dialog")), {action: _this.attr("href")}),
      dialogClass: _this.data("dialog_class")
    });
    event.preventDefault();
    return false; 
  }
  
  this.setupAjaxListener = function() {
     $(".button[data-remote='true'][disabled!=disabled]")
      .live("ajax:beforeSend", Buttons.ajaxBeforeSend)
      .live("ajax:success", Buttons.ajaxSuccess)
      .live("ajax:error", Buttons.ajaxError); 
      
     $("form[data-remote='true']")
      .live("ajax:beforeSend", Buttons.ajaxBeforeSendForm)
      .live("ajax:success", Buttons.ajaxSuccessForm)
      .live("ajax:error", Buttons.ajaxErrorForm);
  }
  
  this.ajaxBeforeSend = function(event, request, settings) {
    Buttons.addLoading($(event.currentTarget));
  }
  
  this.ajaxSuccess = function(event, request, settings) {
    var _this = $(event.currentTarget);
    Buttons.removeLoading(_this);
    
    eval($(_this).data("on_success"));
  }
  
  this.ajaxError = function(event, request, settings) {
    var _this = $(event.currentTarget);
    Buttons.removeLoading(_this);
    
    Dialog.add({
      trigger: _this,
      content: $.tmpl(_this.data("rel")+"_error", eval(_this.data("ref_for_dialog"), {error: request.responseText})),
      dialogClass: _this.data("dialog_class")+" error"
    });
  }
  
  this.ajaxBeforeSendForm = function(event, request, settings) {
    Buttons.addLoading($(event.currentTarget).find(".button[type='submit']"));
  }
  
  this.ajaxSuccessForm = function(event, request, settings) {
    var _this = $(event.currentTarget).find(".button[type='submit']");
    Buttons.removeLoading($(_this));
    var dialog_trigger = $(event.currentTarget).parents(".dialog").data("trigger").parents(".line");
    $(event.currentTarget).parents(".dialog").dialog("close");
    eval($(_this).data("on_success"));
  }
  
  this.ajaxErrorForm = function(event, request, settings) {
    Buttons.removeLoading($(event.currentTarget).find(".button[type='submit']"));
    $(event.currentTarget).find(".flash_message").html(request.responseText).show();
    $(event.currentTarget).closest(".ui-dialog").css("height", "auto");
    $(event.currentTarget).find(".comment").hide();
  }
  
  this.addLoading = function(element) {
    Buttons.disable(element);
    if($(element).children(".icon").length > 0) {
      $(element).find(".icon").hide().after(Buttons.loadingImg);
    } else {
      var text = $(element).html();
      $(element).data("text", text).width($(element).outerWidth()).html("").append(Buttons.loadingImg);      
    } 
  }
  
  this.removeLoading = function(element) {
    Buttons.enable(element);
    $(element).find(".loading").remove();
    if($(element).children(".icon").length > 0) {
      $(element).find(".icon").show();
    } else {
      $(element).width("auto").html($(element).data("text"));      
    } 
  }
  
  this.disable = function(element) {
    $(element).bind("click", Buttons.preventDefaultClick);
    $(element).attr('disabled', true);
  }
  
  this.enable = function(element) {
    $(element).unbind("click", Buttons.preventDefaultClick);
    $(element).removeAttr('disabled');
  }
  
  this.preventDefaultClick = function(event) {
    event.preventDefault();
    return false; 
  }
}