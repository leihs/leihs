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
   
    this.checkPosition = function (_object) {
        $(_object).css("display", "block")
        
        if(window.pageYOffset > $(_object).offset().top){
            // top is higher then viewport
            $(_object).offset({top: window.pageYOffset + 5});
            
            // show or hide arrows dedicated to their position in the viewport
            if($(_object).parent().offset().top - window.pageYOffset < 0) {
                $(_object).find(".inner .borderleft .arrow").hide();
                $(_object).find(".inner .borderright .arrow").hide();
            } else {
                $(_object).find(".inner .borderleft .arrow").show();
                $(_object).find(".inner .borderright .arrow").show();
            }
            
            // positioning arrows
            $(_object).find(".inner .borderleft .arrow").offset({top: $(_object).parent().offset().top+14});
            $(_object).find(".inner .borderright .arrow").offset({top: $(_object).parent().offset().top+14});
        } else if(($(_object).parent().offset().top +  $(_object).height()) > (window.pageYOffset +  window.innerHeight)) {
            // bottom of object is lower then viewport
            $(_object).offset({top: (window.pageYOffset +  window.innerHeight - $(_object).height() - 15)});
            
            // show or hide arrows dedicated to their position in the viewport
            if($(_object).parent().offset().top > (window.pageYOffset +  window.innerHeight - 80)) {
                $(_object).find(".inner .borderleft .arrow").hide();
                $(_object).find(".inner .borderright .arrow").hide();
            } else {
                $(_object).find(".inner .borderleft .arrow").show();
                $(_object).find(".inner .borderright .arrow").show();
            }
            
            // positioning arrows
            $(_object).find(".inner .borderleft .arrow").offset({top: $(_object).parent().offset().top+14});
            $(_object).find(".inner .borderright .arrow").offset({top: $(_object).parent().offset().top+14});
        } else {
            // normal position
            $(_object).offset({top: $(_object).parent().offset().top-50});
            
            // show or hide arrows dedicated to their position in the viewport
            if($(_object).parent().offset().top - window.pageYOffset < 0) {
                $(_object).find(".inner .borderleft .arrow").hide();
                $(_object).find(".inner .borderright .arrow").hide();
            } else {
                $(_object).find(".inner .borderleft .arrow").show();
                $(_object).find(".inner .borderright .arrow").show();
            }
            
            // positioning arrows
            $(_object).find(".inner .borderleft .arrow").offset({top: $(_object).parent().offset().top+14});
            $(_object).find(".inner .borderright .arrow").offset({top: $(_object).parent().offset().top+14});
        }
        
        $(_object).css("display", "none");
    }
    
    this.setupBindings = function() {
        // MOUSEENTER
        $('#models #modellist .imagehover').bind('mouseenter', function(){
            $(this).attr("over", "true");
            ModelsHover.hovering = "true";
            if(ModelsHover.hoveringMode == "true") {
                $(this).find(".hover").hide(0, function(){
                    if($(this).parent().attr("over") == "true") {
                        $(this).stop().show(0, function() {
                            ModelsHover.checkPosition($(this));
                        });
                    } else {
                        $(this).stop().hide();                    
                    }
                });
            } else {
                $(this).find(".hover").delay(800).hide(0, function(){
                    ModelsHover.hoveringMode = "true";
                    if($(this).parent().attr("over") == "true") {
                        $(this).stop().show(0, function() {
                            ModelsHover.checkPosition($(this));
                        });
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
            $(this).find(".hover").stop().hide(0, function() {
                $(this).position({top: 0});
                $(this).removeAttr("style");
                $(this).find(".inner .borderleft .arrow").removeAttr("style");
                $(this).find(".inner .borderright .arrow").removeAttr("style");
            });
            $(this).find(".hover").delay(400).hide(0, function() {
                if(ModelsHover.hovering == "false") {
                    ModelsHover.hoveringMode = "false";
                }
            });
        });
    }
}