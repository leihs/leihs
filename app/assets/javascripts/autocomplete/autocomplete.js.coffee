###

  Autocomplete

  This script provides functionalities for autocompleting things 
  
###

jQuery ->
  $("input.autocomplete").live "focus", (event)->
    if not $(this).hasClass("ui-autocomplete-input")
      new AutoComplete $(this)
  $("input.autocomplete").live "focus", (event)->
    el = $(this)
    do (el)->
      search = -> 
        if el.val().length
          el.autocomplete("search")
      setTimeout search, 150

class AutoComplete
  
  constructor: (input_field)->
    @setup input_field
    do @delegateEvents
    
  delegateEvents: =>
    @el.bind "blur", (event)=>
      @current_ajax.abort() if @current_ajax?
      do @deselect unless @el.val().length
  
  setup: (input_field, source)=>
    @el = $(input_field)
    @el.data("_autocomplete", @this)
    @data = @el.data()
    @el.autocomplete
      source: if source? then source else if @data.autocomplete_data? then @data.autocomplete_data else if @data.url then @remote_source
      select: @select
      focus: @focus
      appendTo: @el.closest("div")
    # add class name to autocomplete widget
    @el.autocomplete("widget").addClass @data.autocomplete_class
    # show on focus
    if @data.autocomplete_search_on_focus == true
      @el.bind "focus", (event)=>
        @el.autocomplete("option", "minLength", 0)
        @el.autocomplete("search", "")
        @el.autocomplete("widget").position
          of: @el
          my: "left top"
          at: "left bottom"
        window.setTimeout => 
          @el.select() if @el.is ":focus"
        , 100
    # render autocomplete item
    if @data.autocomplete_element_tmpl?
      @el.data("autocomplete")._renderItem = (ul, item)=>
        $( "<li></li>" ).data("item.autocomplete", item).append( $.tmpl(@data.autocomplete_element_tmpl, item) ).appendTo(ul)

  remote_source: (request, response)=>
    data = {format: "json"}
    data[@data.autocomplete_search_attr ? "term"] = request.term
    data = $.extend(true, data, {with: @data.autocomplete_with}) if @data.autocomplete_with?
    @el.autocomplete("widget").scrollTop 0
    @current_ajax.abort() if @current_ajax?
    @current_ajax = $.ajax 
      url: @data.url
      data: data
      dataType: "json"
      beforeSend: =>
        @el.next(".loading").remove()
        @el.next(".icon").hide()
        @el.after LoadingImage.get()
        @el.autocomplete("close")
      complete: =>
        @el.next(".loading").remove()
        @el.next(".icon").show()
      success: (data)=>
        # compute entries
        data = data.entries if data.entries?
        entries = $.map data, (element)=> 
          element.label = if @data.autocomplete_display_attribute? then element[@data.autocomplete_display_attribute] else element.label
          element.value = element[@data.autocomplete_value_attribute] if @data.autocomplete_value_attribute?
          element
        # setup autocomplete search only once & only search on focus
        if @data.autocomplete_search_only_on_focus? or @data.autocomplete_search_only_once?
          @setup @el, entries
          @el.bind "blur", ()=> @setup @el, @source  
        # return entries
        response entries

  select: (event, element)=>
    if @data.autocomplete_clear_input_value_on_select is true
      @el.val ""
    else
      @el.val element.item[@data.autocomplete_display_attribute]
    @el.autocomplete("close")
    value = if @data.autocomplete_value_attribute? then element.item[@data.autocomplete_value_attribute] else element.item.value
    if @data.autocomplete_value_target?
      $("input[name='#{@data.autocomplete_value_target}']").val(value).change()
    if @data.autocomplete_select_callback?
      el = $(event.currentTarget)
      callback = eval @data.autocomplete_select_callback
      if callback?
        callback(element, event)
    @el.blur() if @data.autocomplete_blur_on_select == true
    @el.trigger("autocomplete:select",[element])
    return false

  deselect: =>
    $("input[name='#{@data.autocomplete_value_target}']").removeAttr("value").change()

  focus: (event, ui)=> false
    
window.AutoComplete = AutoComplete
