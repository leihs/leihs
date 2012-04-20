###

  Line

  This script provides functionalities for the generic Line
  
###

class Line
  
  @remove = (options)->
    $(options.element).trigger('before_remove_line', [options])
    
    # animate and remove    
    $(options.element).css("background-color", options.color).fadeOut 400, ()->
      if $(this).closest(".linegroup").find(".lines .line").length == 1
        if $(this).closest(".visit").find(".line").length == 1
          $(this).closest(".visit").remove()
        else
          $(this).closest(".indent").next("hr").remove()
          $(this).closest(".indent").remove()
      else
        $(this).remove()    
      
    options.callback() if options.callback? 
    $(document).trigger('after_remove_line', [options])
      
  @get_problems = (data)->
    problems = []
    problems.push "The model is not available" if data.is_available == false
    return problems
  
  @highlight = (line_element, type)->
    $(line_element).addClass("highlight #{type}")
    setTimeout ()->
      $(line_element).removeClass("highlight #{type}")  
    , 300
    
  @recompute_availability = (line_data)->
    availability = line_data.availability_for_inventory_pool.availability
    line_id = line_data.id
    line_type = line_data.type
    
    # for change in availability
      # allocations = change[2]
      # for allocation in allocations
        # for out_document_line in allocation.out_document_lines[]     
    
        
window.Line = Line