###

jQuery Plugin for having a delayedChange event triggered even when the field was not blured 

after the default waiting time or the one that is provided with options.delay

###

$ = jQuery

$.extend $.fn, delayedChange: (options)-> @each -> $(this).data('_delayed_change', new DelayedChange(this, options)) unless $(this).data("_delayed_change")?

class window.DelayedChange
  
  constructor:(target, options)->
    @delay = if options? and options.delay? then options.delay else 500 
    @target = target
    do @delegateEvents
    this
    
  delegateEvents: ->
    validate = (e)=>
      target = $ e.currentTarget
      @validate({})
    if typeof @target is "string"
      $(document).on "keydown mousedown change", @target, validate
      $(document).on "keyup", @target, @validate
    else
      $(@target).on "keydown mousedown change", validate
      $(@target).on "keyup", @validate
    
  validate: (e)=>
    target = $ e.currentTarget
    clearTimeout target.data("timeout") if target.data("timeout")?
    target.data "timeout", setTimeout =>
      target.trigger("delayedChange") if target.data("lastValue") != target.val()
      target.data "lastValue", target.val()
    , @delay