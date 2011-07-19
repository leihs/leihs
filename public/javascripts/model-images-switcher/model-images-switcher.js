/*
 * Model Images Switcher
 *
 * This script provides functionalities to switch images of a model easily on the show-view
 *
 * @name Model Images Switcher
 * @author Sebastian Pape <email@sebastianpape.com>
*/

$(document).ready(function(){
	ImageSwitcher.setupBindings();
});

var ImageSwitcher = new ImageSwitcher();

function ImageSwitcher() {
    
    this.setupBindings = function() {
        // MOUSEENTER
        $('#model #smallimages img').bind('mouseenter', function(){
            hoveredItem = $(this);
            $('#model #hiddenimages img').each(function() {
                $(this).stop().hide();
                if($(this).attr('src') == hoveredItem.attr('src').replace(/_thumb/g, "")) {
                    $(this).stop().fadeIn();
                    $('#model #bigimage img').stop().animate({
                        opacity: 0
                    });
                }
            });
        });
        
        // MOUSELEAVE
        $('#model #smallimages img').bind('mouseleave', function(){
            hoveredItem = $(this);
            $('#model #hiddenimages img').each(function() {
                if($(this).attr('src') == hoveredItem.attr('src').replace(/_thumb/g, "")) {
                    if($(this).css("opacity") != 1) {
                        $(this).removeAttr("style");
                    }
                    $(this).stop().fadeOut(400, function(){
                        $(this).removeAttr("style");
                    });
                    $('#model #bigimage img').stop().animate({
                        opacity: 1
                    });
                }
            });
        });
    }
}