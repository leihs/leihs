###

  Autocomplete

  This script provides functionalities for autocompleting things 
###

jQuery ->
  $("input.autocomplete").live "focus", (event)->
    if not $(this).hasClass("ui-autocomplete-input")
      AutoComplete.setup $(this)
    else if $(this).val() != ""
      $(this).autocomplete("widget").show()
    
class AutoComplete
  
  @setup = (input_field)->
    $(input_field).autocomplete
      source: @source
      select: @select
    $(input_field).autocomplete("widget").addClass($(input_field).data("autocomplete_class"))
  
  @source = (request, response)->
    trigger = $(this.element)
    $.ajax 
      url: $(trigger).data("url")
      data:
        format: "json"
        query: request.term
      dataType: "json"
      beforeSend: ->
        $(trigger).next(".loading").remove()
        $(trigger).after LoadingImage.get()
      complete: ->
        $(trigger).next(".loading").remove()
      success: (data)->
        entries = $.map(data, (element)-> { id: element.id, value: Str.sliced_trunc(element.name, 45) })
        response entries
      
  @select = (event, element)->
    if $(this).data("autocomplete_select_callback")?
      callback = eval $(this).data("autocomplete_select_callback")
      if callback?
        callback(element)
        return false

window.AutoComplete = AutoComplete