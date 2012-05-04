###

Purpose

This script provides functionalities to add purpose to an hand over
 
###
   
class Purpose
  
  @setup: ->
    $(".dialog .purpose button").live "click", (e)->
      e.preventDefault()
      if $(".dialog .add_purpose:visible").length == 0
        $(this).hide()
        $(".dialog .add_purpose").show()
        $(".dialog .add_purpose #purpose").addClass("focus").focus()
        Dialog.rescale $(".dialog")
      return false
    
window.Purpose = Purpose