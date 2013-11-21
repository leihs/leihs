###

  Autocomplete

  This script provides functionalities for autocompleting things 
  for Item editing (flexible fields)
  
###

jQuery ->
  $("input[data-type='autocomplete']").live "focus", (event)->
    if not $(this).hasClass("ui-autocomplete-input")
      new AutoComplete $(this)
  $("input[data-type='autocomplete']").live "focus", (event)->
    el = $(this)
    do (el)->
      search = -> 
        if el.val().length and el.is(":focus")
          el.autocomplete("search")
      setTimeout search, 150

class AutoComplete
  
  constructor: (input_field)->
    @setup input_field
    do @delegateEvents
    
  delegateEvents: =>
    @el.bind "blur", (event)=> @current_ajax.abort() if @current_ajax?
    @el.bind "change", @onChange
  
  setup: (input_field, source)=>
    @el = $(input_field)
    @el.data("_autocomplete", @this)
    @data = @el.data()
    @el.autocomplete
      source: if source? then source else if @data.autocomplete_data? then @data.autocomplete_data else if @data.url then @remote_source
      select: @select
      focus: @focus
      appendTo: @el.closest("form")
    # add class name to autocomplete widget
    @el.autocomplete("widget").addClass @data.autocomplete_class
    # show on focus
    if @data.autocomplete_search_on_focus == true
      @el.bind "focus", (event)=>
        @el.autocomplete("option", "minLength", 0)
        @el.autocomplete("search", "")
        @el.autocomplete("widget").position
          of: @el
          my: "right top"
          at: "right bottom"
        window.setTimeout => 
          @el.select() if @el.is ":focus"
        , 100
    # render autocomplete item
    if @data.autocomplete_element_tmpl?
      @el.data("uiAutocomplete")._renderItem = (ul, item) => 
        $(App.Render(@data.autocomplete_element_tmpl, item)).data("value", item).appendTo(ul)

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
    value = if @data.autocomplete_value_attribute? then element.item[@data.autocomplete_value_attribute] else element.item.value
    @el.blur() if @data.autocomplete_blur_on_select == true
    if @data.autocomplete_value_target?
      @el.prevAll("input[name='#{@data.autocomplete_value_target}']").val(value).change()
    if @data.autocomplete_select_callback?
      el = $(event.currentTarget)
      callback = eval @data.autocomplete_select_callback
      if callback?
        callback(element, event)
    @setExtendedValue()
    return false

  focus: (event, ui)=> false

  onChange: (e) =>
    target = $(e.currentTarget)
    @setExtendedValue()
    $("input[name='#{@data.autocomplete_value_target}']").val null

  setExtendedValue: () =>
    if @el.data("autocomplete_extensible")
      @el.prevAll("input[name='#{@data.autocomplete_extended_key_target}'][data-type='extended-value']").val @el.val()

window.AutoComplete = AutoComplete