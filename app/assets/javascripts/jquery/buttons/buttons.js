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
  }
  
  this.setupDialogListener = function() {
    $("a.smallbutton.open_dialog").live("click", function(event){
     
      var _this = $(this);
      
      Dialog.add({
        trigger: _this,
        content: $.tmpl(_this.attr("rel"), eval(_this.data("ref_for_dialog")), {action: _this.attr("href")}),
        dialogClass: _this.data("dialog_class")
      });
      
      event.preventDefault();
      return false; 
    });
  }
  
  this.setupAjaxListener = function() {
     $("a.smallbutton[data-remote='true']")
      .live("ajax:beforeSend", Buttons.ajaxBeforeSend)
      .live("ajax:success", Buttons.ajaxSuccess)
      .live("ajax:error", Buttons.ajaxError);
  }
  
  this.ajaxBeforeSend = function(event, request, settings) {
    Buttons.disable(event.target);
    $(event.target).find(".icon").hide().after(Buttons.loadingImg);
  }
  
  this.ajaxSuccess = function(event, request, settings) {
    console.log("SUCCESS");
  }
  
  this.ajaxError = function(event, request, settings) {
    $(event.target).find(".icon").show();
    $(event.target).find(".loading").remove();
    
    Dialog.add({
      trigger: $(event.target),
      title: "Error",
      content: request.responseText,
      buttons: { "Ok": function() {$(this).dialog("close");} }
    });
    
    Buttons.enable(event.target);
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