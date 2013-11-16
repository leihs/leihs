###

jQuery Plugin for having a preChange event triggered even when the field was not blured 

after the default waiting time or the one that is provided with options.delay

###

$ = jQuery

$.extend $.fn, preChange: (options)-> @each -> $(this).data('_delayed_change', new PreChange(this, options)) unless $(this).data("_delayed_change")?

class window.PreChange
  
  constructor:(target, options)->
    @delay = if options? and options.delay? then options.delay else 500 
    @target = target
    do @delegateEvents
    this
    @validates = 0
    @timeouts = 0
    
  delegateEvents: ->
    validate = (e)=>
      target = $ e.currentTarget
      @validate(e)
    if typeof @target is "string"
      $(document).on "keydown mousedown change", @target, validate
      $(document).on "keyup", @target, @validate
    else
      $(@target).on "keydown mousedown change", validate
      $(@target).on "keyup", @validate
    
  validate: (e)=>
    target = $ e.currentTarget
    target.data "lastValue", "" unless target.data("lastValue")?
    target.data "lastValue", "" if e.type == "change"
    if target.data("timeout")?
      clearTimeout target.data("timeout")
      target.data "timeout", null
    target.data "timeout", setTimeout =>
      target.trigger("preChange") if target.data("lastValue") != target.val()
      target.data "lastValue", target.val()
      target.data "timeout", null
    , @delay