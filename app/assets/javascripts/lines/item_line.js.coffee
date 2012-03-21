###
  
  Item Line
  
  This class provides functionalities for the item lines
  
###

class ItemLine
  
  @assign_inventory_code = (event)->
    event.preventDefault
    form = $(this)
    $.ajax
      url: form.attr("action")
      type: form.attr("method")
      data: 
        inventory_code: form.find("input").val()
      success: ()->
        console.log "DONE"
    

window.ItemLine = ItemLine