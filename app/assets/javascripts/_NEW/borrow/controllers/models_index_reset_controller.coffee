class window.App.Borrow.ModelsIndexResetController extends Spine.Controller

  events:
    "click": "resetAllFilter"

  constructor: ->
    super
    @resetContainer = $("#reset-container")

  resetAllFilter: =>
    do @reset
    do @hideResetIcon

  validate: =>
    if @isResetable()
      do @showResetIcon
    else
      do @hideResetIcon

  hideResetIcon: =>
    @el.addClass "hidden"
    @resetContainer.removeClass "padding-left-m"

  showResetIcon: =>
    @el.removeClass "hidden"
    @resetContainer.addClass "padding-left-m"