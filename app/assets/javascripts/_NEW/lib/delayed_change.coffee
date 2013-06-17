###

jQuery Plugin for having a delayedChange event triggered even when the field was not blured 

after the default waiting time of 500 ms or the one that is provided with options.delay

###

$ = jQuery

$.extend $.fn, delayedChange: (options)-> @each -> $(this).data('_delayed_change', new DelayedChange(this, options)) unless $(this).data("_delayed_change")?

class DelayedChange
  
  constructor:(element, options)->
    @delay = if options? and options.delay? then options.delay else 500 
    @target = $(element)
    @last_value = @target.val()
    do @delegate_events 
    this
    
  delegate_events: ->
    @target.on "keydown mousedown change", (e)=> 
      @validate({}) if @target.val().length == 0 and @last_value.length != 0
    @target.on "keyup", @validate
    
  validate: =>
    clearTimeout @timeout if @timeout?
    @timeout = setTimeout =>
      current_value = @target.val()
      @target.trigger("delayedChange") unless @last_value == current_value
      @last_value = current_value
    , @delay
