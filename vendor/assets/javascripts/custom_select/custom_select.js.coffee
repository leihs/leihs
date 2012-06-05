$ = jQuery

$.extend $.fn, custom_select: (options)-> @each -> $(this).data('_custom_select', new CustomSelect(this, options)) unless $(this).data("_custom_select")?

class CustomSelect
  
  @ref
  @text
  @container
  @options
  
  constructor: (element, options)->
    @ref = $(element)
    @options = options
    do @setup
    do @set_text 
    do @delegate_events
    this
    
  setup: (options)->
    @container = $("<div class='custom_select'></div>") 
    @text = $("<div class='select'><span></span></div>")
    @text.append @options.postfix if @options.postfix?
    @ref.after @container
    @container.prepend @ref
    @container.prepend @text
    @text = @text.find("span")
    
  delegate_events: =>
    @ref.on "change", @change
    
  change: => do @set_text
  
  set_text: =>
    text = @ref.find('option:selected').html()
    @ref.attr "title", text 
    text = @options.text_handler(text) if @options.text_handler?
    @text.html text 
