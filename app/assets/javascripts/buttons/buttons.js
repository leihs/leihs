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
  
  this.setup = function() {
    this.preventDefault();
    this.setupAjaxListener();
    this.setupDialogListener();
    this.setupMultibutton();
  }
  
  this.preventDefault = function() {
    $(".button.preventDefault").live("click",function(event){
      event.preventDefault();
    });
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
    var _trigger = $(_this).parent().hasClass("alternatives") ? $(_this).closest(".multibutton") : _this;
    var data = (_this.data("ref_for_dialog") != undefined) ? eval(_this.data("ref_for_dialog")) : {};
    var template = (_this.data("rel") != undefined) ? _this.data("rel") : "";
    
    
    Dialog.add({
      trigger: _trigger,
      content: $.tmpl(template, data, {action: _this.attr("href"), on_success: _this.data("on_success")}),
      dialogClass: _this.data("dialog_class")
    });
    
    // dont loose tmplItem().data
    $(".dialog").tmplItem().data = eval(_this.data("ref_for_dialog"));
    
    // prevent default
    event.preventDefault();
    return false; 
  }
  
  this.setupAjaxListener = function() {
     $(".button[data-remote='true']")
      .live("ajax:beforeSend", Buttons.ajaxBeforeSend)
      .live("ajax:success", Buttons.ajaxSuccess)
      .live("ajax:error", Buttons.ajaxError); 
     
     $("form[data-remote='true'][data-submit_button]")
      .live("ajax:beforeSend", Buttons.ajaxBeforeSendForm)
      .live("ajax:success", Buttons.ajaxSuccessForm)
      .live("ajax:error", Buttons.ajaxErrorForm);
  }
  
  this.ajaxBeforeSend = function(event, request, settings) {
    Buttons.disable($(event.currentTarget));
    Buttons.addLoading($(event.currentTarget));
  }
  
  this.ajaxSuccess = function(event, response, settings) {
    var _this = $(event.currentTarget);
    console.log(_this);
    Buttons.enable(_this);
    Buttons.removeLoading(_this);
    
    eval($(_this).data("on_success"));
  }
  
  this.ajaxError = function(event, response, settings) {
    var _this = $(event.currentTarget);
    Buttons.enable(_this);
    Buttons.removeLoading(_this);
    var _trigger = $(_this).parent().hasClass("alternatives") ? $(_this).closest(".multibutton") : _this;
    
    Dialog.add({
      trigger: _trigger,
      content: $.tmpl(_this.data("rel"), eval(_this.data("ref_for_dialog")), {error: response.responseText, action: _this.attr("href"), on_success: _this.data("on_success")}),
      dialogClass: _this.data("dialog_class")+" error"
    });
  }
  
  this.ajaxBeforeSendForm = function(event, request, settings) {
    Buttons.disable($(event.currentTarget).find(".button[type='submit']"));
    Buttons.addLoading($(event.currentTarget).find(".button[type='submit']"));
  }
  
  this.ajaxSuccessForm = function(event, response, settings) {
    var _this = $(event.currentTarget).find(".button[type='submit']");
    Buttons.enable(_this);
    Buttons.removeLoading(_this);
    
    // execute on success before dialog is closed    
    eval($(_this).data("on_success"));
    
    $(event.currentTarget).parents(".dialog").dialog("close");
  }
  
  this.ajaxErrorForm = function(event, response, settings) {
    Buttons.enable($(event.currentTarget).find(".button[type='submit']"));
    Buttons.removeLoading($(event.currentTarget).find(".button[type='submit']"));
    $(event.currentTarget).find(".flash_message").html(response.responseText).show();
    $(event.currentTarget).closest(".ui-dialog").css("height", "auto");
  }
  
  this.addLoading = function(element) {
    if($(element).children(".icon").length > 0) {
      $(element).find(".icon").hide().after(LoadingImage.get());
    } else {
      $(element).prepend(LoadingImage.get());  
    }
    
    if($(element).parent().hasClass("multibutton") || $(element).parent().hasClass("alternatives")) {
      $(element).closest(".multibutton").addClass("loading"); 
    }
  }
  
  this.removeLoading = function(element) {
    $(element).find(".loading").remove();
    if($(element).children(".icon").length > 0) {
      $(element).find(".icon").show();
    }
    
    if($(element).parent().hasClass("multibutton") || $(element).parent().hasClass("alternatives")) {
      $(element).closest(".multibutton").removeClass("loading"); 
    }
  }
  
  this.disable = function(element) {
    $(element).bind("click", Buttons.preventDefaultClick);
    $(element).attr('disabled', true);
    
    // if button has multibutton parent - disable as well
    if($(element).parent().hasClass("multibutton") || $(element).parent().hasClass("alternatives")) {
      $(element).closest(".multibutton").attr("disabled", true).removeClass("open");
      $(element).closest(".multibutton").find(".button").attr("disabled", true);
      $(element).closest(".multibutton").find(".alternatives .button").hide();
      
      if($(element).parent().hasClass("alternatives")) {
        // change element with first action to see loading indicator
        $(element).after($('<div class="placeholder"></div>'));
        $(element).closest(".multibutton").children(".button").hide();
        $(element).closest(".multibutton").append($(element));
        $(element).show();
      }
    }
  }
  
  this.enable = function(element) {
    $(element).unbind("click", Buttons.preventDefaultClick);
    $(element).removeAttr('disabled');
    
    // if button has multibutton parent - enable as well
    if($(element).parent().hasClass("multibutton") || $(element).parent().hasClass("alternatives")) {
      $(element).closest(".multibutton").removeAttr('disabled');
      
      if($(element).closest(".multibutton").children(".button").length > 1) {
        var giveback_element = $(element).closest(".multibutton").children(".button:visible");
        $(element).closest(".multibutton").find(".alternatives .placeholder").before(giveback_element);
        $(element).closest(".multibutton").find(".alternatives .placeholder").remove();
        $(element).closest(".multibutton").children(".button:hidden").show();
      }
      $(element).closest(".multibutton").find(".button").removeAttr('disabled');
      $(element).closest(".multibutton").find(".alternatives .button").removeAttr("style");
    }
  }
  
  this.preventDefaultClick = function(event) {
    event.preventDefault();
    event.stopImmediatePropagation();
    return false; 
  }
}