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
  $("input.autocomplete").live "blur", (event)-> AutoComplete.current_ajax.abort() if AutoComplete.current_ajax?

class AutoComplete
  
  @current_ajax
  
  @setup = (input_field, source)->
    # initialize autocomplete
    options = {}
    options.source = if source? then source else @source
    options.select = @select
    $(input_field).autocomplete options
    # add class name to autocomplete widget
    $(input_field).autocomplete("widget").addClass($(input_field).data("autocomplete_class"))
    # show on focus
    if $(input_field).data("autocomplete_search_on_focus") == true
      $(input_field).bind "focus", ()->
        $(input_field).autocomplete( "option", "minLength", 0 )
        $(input_field).autocomplete("search", "")
        $(this).autocomplete("widget").position
          of: $(this)
          my: "left top"
          at: "left bottom"
    # render autocomplete item
    if $(input_field).data("autocomplete_element_tmpl")?
      $(input_field).data("autocomplete")._renderItem = (ul, item)->
        $( "<li></li>" ).data("item.autocomplete", item).append( $.tmpl($(input_field).data("autocomplete_element_tmpl"), item) ).appendTo(ul)
      
  @source = (request, response)->
    trigger = $(this.element)
    $(trigger).autocomplete("widget").scrollTop 0
    AutoComplete.current_ajax.abort() if AutoComplete.current_ajax?
    AutoComplete.current_ajax = $.ajax 
      url: $(trigger).data("url")
      data:
        format: "json"
        term: request.term
      dataType: "json"
      beforeSend: ->
        $(trigger).next(".loading").remove()
        $(trigger).next(".icon").hide()
        $(trigger).after LoadingImage.get()
        $(trigger).autocomplete("close")
      complete: ->
        $(trigger).next(".loading").remove()
        $(trigger).next(".icon").show()
      success: (data)->
        # compute entries
        entries = $.map data, (element)-> 
          element.value = element[$(trigger).data("autocomplete_value_attribute")] if $(trigger).data("autocomplete_value_attribute")?
          element
        # setup autocomplete search only once & only search on focus
        if $(trigger).data("autocomplete_search_only_on_focus")? or $(trigger).data("autocomplete_search_only_once")?
          AutoComplete.setup trigger, entries
          $(trigger).bind "blur", ()-> AutoComplete.setup(trigger, AutoComplete.source)  
        # return entries
        response entries
      
  @select = (event, element)->
    $(this).val("")
    $(this).autocomplete("close")
    if $(this).data("autocomplete_select_callback")?
      callback = eval $(this).data("autocomplete_select_callback")
      if callback?
        callback(element, event)
        return false

window.AutoComplete = AutoComplete