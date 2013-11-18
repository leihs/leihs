###

App.Tooltip

This script provides functionalities for tooltips.

Either use the title tag in an element with the class "tooltip"
or create an Tooltip with new App.Tooltio(options).

###

class App.Tooltip

  @origins = []
  @interactive = true

  constructor: (options)->
    @target = $(options.el).tooltipster
      animation: 'fade',
      arrow: true,
      content: options.content,
      delay: if options.delay? then options.delay else 150,
      fixedWidth: 0,
      maxWidth: 0,
      interactive: if options.interactive? then options.interactive else App.Tooltip.interactive,
      interactiveTolerance: 500,
      offsetX: 0,
      offsetY: -12,
      onlyOne: true,
      position: 'top',
      speed: 150,
      timer: 0,
      touchDevices: true,
      trigger: if options.trigger? then options.trigger else 'hover',
      updateAnimation: true
      functionBefore: (origin, continueTooltip)=>
        continueTooltip()
        tooltip = origin.data("tooltipster")
        tooltip.addClass options.className if options.className?
        @delegateEvents tooltip
        options.callback(origin, tooltip) if options.callback?
    if options.content?        
      @content = options.content
      @target.tooltipster("show")

  delegateEvents: (tooltip)=>
    tooltip.find("img").load @reposition

  disable: => @target.tooltipster "disable"

  enable: => @target.tooltipster "enable"

  update: (content) =>
    @content = content
    @target.tooltipster "update", content
    do @reposition

  reposition: => @target.tooltipster "reposition"

  show: => @target.tooltipster "show"

  @destroyAll: =>
    for tooltip in $(".tooltipster-base:not(.tooltipster-dying)")
      tooltip = $(tooltip)
      if tooltip.data("origin")?
        tooltip.data("origin").tooltipster("destroy")
      else
        tooltip.remove()

  @hideAll: =>
    for tooltip in $(".tooltipster-base:not(.tooltipster-dying)")
      tooltip = $(tooltip)
      if tooltip.data("origin")?
        tooltip.data("origin").tooltipster("hide")
      else
        tooltip.hide()

window.App.Tooltip = App.Tooltip

jQuery -> 
  $(document).on "mouseenter", ".tooltip[title], .tooltip[data-tooltip-data]", (e)-> 
    template = if $(this).data("tooltip-template")? then $(this).data("tooltip-template") else "views/tooltips/default"
    $(this).data("tooltip-data", $(this).attr("title")) if $(this).attr("title")? and not $(this).data("tooltip-data")?
    $(this).removeAttr "title"
    content = $(this).data("tooltip-data")
    target = if $(this).closest(".line-col").length then $(this).closest(".line-col") else $(this)
    new App.Tooltip
      el: target
      content: App.Render(template, {content: content})