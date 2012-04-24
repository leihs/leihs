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

  @remove_line_from_availability = (line_data, availability)->
    return undefined if not availability?
    availability = line_data.availability_for_inventory_pool.availability
    line_type = Underscore.str.classify(line_data.type)
    for change in availability
      allocations = change[2]
      for allocation in allocations
        if allocation.out_document_lines[line_type]? and (allocation.out_document_lines[line_type].indexOf(line_data.id) > -1)
          allocation.out_document_lines[line_type] = _.filter allocation.out_document_lines[line_type], (line)-> line != line_data.id
          allocation.in_quantity += line_data.quantity
          change[1] += line_data.quantity
    availability
    
  @get_user: (lines_data)->
    return lines_data.order.user if lines_data.order? and lines_data.order.user?
    return lines_data.contract.user if lines_data.contract? and lines_data.contract.user?
    return lines_data.user

window.Line = Line