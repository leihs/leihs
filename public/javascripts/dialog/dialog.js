/*
 * Dialog
 *
 * This script setups the dialog jqueryui element with predefined settings
 * so you dont have to call all the options when you just open a dialog
 *
 * @name Dialog
 * @author Sebastian Pape <email@sebastianpape.com>
*/

$(document).ready(function(){
    // positioning of all dialogs (center)
    $(window).resize(function() {
        $(".ui-dialog ").position({of: $(window), at: "center center"});
    });
});

var Dialog = new Dialog();

function Dialog() {
    
    this.add = function(_trigger, _content, _nativeParams) {
        var _dialog = $(document.createElement("div")).addClass("dialog").html(_content);
        $("body").append(_dialog);
        $(_dialog).data("trigger", $(_trigger));
        Dialog.setup(_dialog);
        _dialog.dialog(_nativeParams);
    }
    
    this.setup = function(_dialog) {
        $(_dialog).bind("dialogcreate", function(event, ui) {
            $(this).dialog("option", "modal", true);
            $(this).dialog("option", "draggable", false);
        });
        
        $(_dialog).bind("dialogopen", function(event, ui) {
            // bind click on overlay to close dialog 
            $(".ui-widget-overlay").bind("click", function(){
                $(_dialog).dialog("close");
            });
            
            // openanimation
            $(_dialog).offset({top: 0, left: 0});
        });
        
        $(_dialog).bind("dialogclose", function(event, ui) {
            // remove dialog on close
            $(this).remove();
        });
    }
    
}