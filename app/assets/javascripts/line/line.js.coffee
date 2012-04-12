###

  Line

  This script provides functionalities for the generic Line
  
###

class Line
  
  @remove = (options)->
    $(options.element).trigger('before_remove_line', [options])
    if $(options.element).closest("linegroup").length
      @remove_element_of_a_line_group(options)
    else
      @remove_element_of_a_list(options)
    options.callback() if options.callback? 
    $(document).trigger('after_remove_line', [options])
    
  @remove_element_of_a_line_group = (options)->
    $(options.element).css("background-color", options.color).fadeOut 400, ()->
      if $(this).closest(".linegroup").find(".lines .line").length == 1
        $(this).closest(".indent").next("hr").remove()
        $(this).closest(".indent").remove()
      else
        $(this).remove()
  
  @remove_element_of_a_list = (options)->
    parent = $(options.element).parents(".list")
    $(options.element).css("background-color", options.color).fadeOut 400, ()->
      List.remove(options.element)
      
  @get_problems = (data)->
    problems = []
    problems.push "The model is not available" if data.is_available == false
    return problems
        
window.Line = Line