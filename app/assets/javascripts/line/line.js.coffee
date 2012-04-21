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
    line_type = Underscore.str.classify(line_data.type)
    line_data.is_available = true
    for change in availability
      break if line_data.is_available == false
      allocations = change[2]
      for allocation in allocations
        if allocation.out_document_lines[line_type]? and (allocation.out_document_lines[line_type].indexOf(line_data.id) > -1) and (allocation.in_quantity < 0)
          line_data.is_available = false
          break

window.Line = Line