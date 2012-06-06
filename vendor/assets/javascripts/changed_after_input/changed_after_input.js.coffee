$ = jQuery

$.extend $.fn, changed_after_input: (options)-> @each -> $(this).data('_changed_after_input', new ChangedAfterInput(this, options)) unless $(this).data("_changed_after_input")?

class ChangedAfterInput
  
  @target
  @timeout
  @delay
  @last_value
  
  constructor:(element, options)->
    @delay = if options? and options.delay? then options.delay else 500 
    @target = $(element)
    do @delegate_events 
    this
    
  delegate_events: ->
    @target.on "keyup", @validate
    @target.on "keydown mousedown change", => @last_value = @target.val()
    
  validate: (e)=>
    clearTimeout @timeout if @timeout?
    @timeout = setTimeout =>
      @target.trigger("changed_after_input") if @target.val() != @last_value
      @last_value = @target.val()  
    , @delay