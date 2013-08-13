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
      if($(this).offset().top-$(window).scrollTop()+$(this).height() > $(window).height()) {
        container = $("<div class='converse'></div>")
        $(this).find(".button").appendTo(container);
        $(this).append(container);
        var top = 31 + container.height();
        container.css("position", "absolute")
        container.css("top", "-"+top+"px");
        container.css("right", "0px");
        container.css("width", "100%");
      }
    });
    
    $(".multibutton").live("mouseleave", function(){
      $(this).closest(".multibutton").removeClass("open");
    });
    
    $(".multibutton[disabled=disabled] .button").live("click mousedown", function(event){
      event.preventDefault();
      return false;
    });
    
    $(".multibutton .button").live("click", function(event){
      // close multibutton
      _button = this
      $(_button).closest(".multibutton").find(".alternatives .button").hide()
      setTimeout(function(){
        $(_button).closest(".multibutton").find(".alternatives .button").removeAttr("style")  
      },200);
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
  
  this.openDialog = function(event, response) {
    var _this = $(event.currentTarget);

    var createDialog = function(data) {
      var template = (_this.data("tmpl") != undefined) ? _this.data("tmpl") : undefined;
      var content, class_name, error;

      if(template != undefined) {
        var target_url = _this.attr("href");
        var options = {target_url: target_url, on_success: _this.data("on_success")};
        class_name = _this.data("dialog_class");
        if (event.type == "ajax:error"){
          additional_class = "error";
          options.error = response.responseText;
          class_name += " error";
        }
        content = $.tmpl(template, (data == undefined) ? {} : data, options);
      } else {
        content = data;
      }   

      var dialog = Dialog.add({
        trigger: _this,
        content: content,
        dialogClass: class_name,
        dialogId: (_this.data("dialog_id") != undefined) ? _this.data("dialog_id") : undefined
      });

      // don't loose tmplItem().data
      $(".dialog").tmplItem().data = data;
    }

    // create dialog either for data or for a async data (url)    
    if(_this.data("ref_for_dialog") != undefined) { // data
      createDialog(eval(_this.data("ref_for_dialog")));
    } else if(_this.data("url_for_dialog") != undefined) { // url
      $.ajax({
        url: _this.data("url_for_dialog"),
        type: "GET",
        beforeSend: function(){
          Buttons.disable($(event.currentTarget));
          Buttons.addLoading(_this);
        },
        success: function(response_data){
          createDialog(response_data);    
        },
        complete: function(){
          Buttons.enable(_this);
          Buttons.removeLoading(_this);
        }
      });
    } else {
      createDialog();
    }
  
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
    Buttons.enable(_this);
    Buttons.removeLoading(_this);
    eval($(_this).data("on_success"));
  }
  
  this.ajaxError = function(event, response, settings) {
    var _this = $(event.currentTarget);
    Buttons.enable(_this);
    Buttons.removeLoading(_this);
    Buttons.openDialog(event, response);
  }
  
  this.ajaxBeforeSendForm = function(event, request, settings) {
    Buttons.disable($(event.currentTarget).find(".button[type='submit']:visible:first"));
    Buttons.addLoading($(event.currentTarget).find(".button[type='submit']:visible:first"));
  }
  
  this.ajaxSuccessForm = function(event, response, settings) {
    var _this = $(event.currentTarget).find(".button[type='submit']");
    Buttons.enable(_this);
    Buttons.removeLoading(_this);
    // execute on success before dialog is closed TODO: change eval to a real function call
    if($(_this).data("on_success") != null && $(_this).data("on_success") != ""){
      eval($(_this).data("on_success"));
    }
    
    // close dialog    
    $(event.currentTarget).parents(".dialog").dialog("close");
  }
  
  this.ajaxErrorForm = function(event, response, settings) {
    Buttons.enable($(event.currentTarget).find(".button[type='submit']"));
    Buttons.removeLoading($(event.currentTarget).find(".button[type='submit']"));
    $(event.currentTarget).find(".flash_message").html(response.responseText).show();
    $(event.currentTarget).closest(".ui-dialog").css("height", "auto");
    $(event.currentTarget).find(".show_on_error").show();
    $(event.currentTarget).find(".hide_on_error").hide();
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