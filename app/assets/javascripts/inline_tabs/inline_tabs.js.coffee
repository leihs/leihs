###

Inline Tabs

This script provides functionalities for inline tabs
 
###

jQuery ->
  
  $(".inlinetabs .tab").live "click", (e)->
    $(this).closest(".inlinetabs").find(".active").removeClass("active")
    $(this).removeClass("inactive").addClass("active")
    $(this).closest(".inlinetabs").nextAll("section").removeClass("active")
    $(this).closest(".inlinetabs").nextAll("section .#{$(this).data('section')}").addClass("active")
