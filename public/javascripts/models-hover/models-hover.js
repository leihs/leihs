/*
 * Models Hover
 *
 * This script provides functionalities for the hover pop up on the "Models Index View"
 *
 * @name Models Hover
 * @author Sebastian Pape <email@sebastianpape.com>
*/

$(document).ready(function(){
	ModelsHover.setupBindings();
});

var ModelsHover = new ModelsHover();

function ModelsHover() {
    
    this.hovering = "false";
    this.hoveringMode = "false";
    
    this.setupBindings = function() {
        // MOUSEENTER
        $('#models #modellist .imagehover').bind('mouseenter', function(){
            $(this).attr("over", "true");
            ModelsHover.hovering = "true";
            if(ModelsHover.hoveringMode == "true") {
                $(this).find(".hover").hide(0, function(){
                    if($(this).parent().attr("over") == "true") {
                        $(this).stop().show();
                    } else {
                        $(this).stop().hide();                    
                    }
                });
            } else {
                $(this).find(".hover").delay(600).hide(0, function(){
                    ModelsHover.hoveringMode = "true";
                    if($(this).parent().attr("over") == "true") {
                        $(this).stop().show();
                    } else {
                        $(this).stop().hide();                    
                    }
                });
            }
        });
        
        // MOUSELEAVE
        $('#models #modellist .imagehover').bind('mouseleave', function(){
            $(this).attr("over", "false");
            ModelsHover.hovering = "false";
            $(this).find(".hover").stop().hide();
            $(this).find(".hover").delay(600).hide(0, function() {
                if(ModelsHover.hovering == "false") {
                    ModelsHover.hoveringMode = "false";
                }
            });
        });
    }
}