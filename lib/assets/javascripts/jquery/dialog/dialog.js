/*
 * Dialog
 *
 * This script setups the dialog jqueryui element with predefined settings
 * so you dont have to call all the options when you just open a dialog
 *
 * @name Dialog
 * @dependencies jQuery.UI (Dialog)
*/

$(document).ready(function(){
  // positioning of all dialogs (centering) when window is resized or scrolled
  $(window).bind("resize scroll", function() {
    clearTimeout(Dialog.followViewPortDelayTimer);
    Dialog.followViewPortDelayTimer = setTimeout(function() {
      var _top = Dialog.padding + window.pageYOffset;
      var _left = ( ( $(window).width()/2 ) - ( $(".ui-dialog ").width()/2 ) + window.pageXOffset );
      $(".ui-dialog ").stop(true, true).animate({
          top: _top,
          left: _left,
      }, {queue: false, duration: Dialog.followViewPortAnimationTime});   
    }, Dialog.followViewPortDelay);
  });
});

var Dialog = new Dialog();

function Dialog() {
  
    this.followViewPortDelayTimer;
    this.followViewPortDelay = 115;
    this.followViewPortAnimationTime = 400;
    this.padding = 120;
  
    this.add = function(_params) {
        var _dialog = $(document.createElement("div")).addClass("dialog").html(_params.content);
        $("body").append(_dialog);
        $(_dialog).data("startLeft", ($(_params.trigger).offset().left + $(_params.trigger).width()/2));
        $(_dialog).data("startTop", ($(_params.trigger).offset().top + $(_params.trigger).height()/2));
        $(_dialog).data("callback", _params.callback);
        
        Dialog.setup(_dialog);
        _params.closeText = "X"
        _dialog.dialog(_params);
    }
    
    this.setup = function(_dialog) {
        $(_dialog).bind("dialogcreate", function(event, ui) {
            $(this).dialog("option", "modal", true);
            $(this).dialog("option", "draggable", false);
            $(this).dialog("option", "resizable", false);
            $(this).parent().css({opacity: 0});
        });
        
        $(_dialog).bind("dialogopen", function(event, ui) {
            // bind click on overlay to close dialog 
            $(".ui-widget-overlay").bind("click", function(){
                $(_dialog).dialog("close");
            });
            
            // popup animation
            $(this).parent().offset({left: ( $(this).data("startLeft") - ( $(this).parent().width()/2 )), top: ( $(this).data("startTop") - $(this).parent().height()/2)});
            
            var _top = Dialog.padding + window.pageYOffset;
            var _left = ( ( $(window).width()/2 ) - ( $(this).parent().width()/2 ) + window.pageXOffset );
            
            $(this).parent().stop(true, true).hide().fadeIn().animate({
                top: _top,
                left: _left,
                opacity: 1
            }, {queue: false});
        });
        
        $(_dialog).bind("dialogclose", function(event, ui) {
            if ($(this).data("callback")) $(this).data("callback").apply();
            
            // remove dialog on close
            $(this).remove();
        });
    }
    
}