class window.App.Borrow.CurrentOrderShowController extends Spine.Controller

  elements:
    "#current-order-lines": "linesContainer"
    ".emboss.red": "conflictsWarning"

  events:
    "click [data-change-order-lines]": "changeOrderLines"

  constructor: ->
    super
    new App.Borrow.ModelsShowPropertiesController {el: "#properties"}
    new App.Borrow.ModelsShowImagesController {el: "#images"}
    unless App.Order.current.timedOut
      @timeoutCountdown = new App.Borrow.TimeoutCountdownController
        el: @el.find("#timeout-countdown")
        refreshTarget: @el.find("#timeout-countdown")
    
  delegateEvents: =>
    super
    App.Order.bind "refresh", (data)=>
      do @render

  changeOrderLines: (e)=>
    do e.preventDefault
    target = $(e.currentTarget)
    new App.Borrow.OrderLinesChangeController 
      modelId: target.data("model-id")
      lines: _.map target.data("line-ids"), (id) -> App.OrderLine.find id
      quantity: target.data("quantity")
      startDate: target.data("start-date")
      endDate: target.data("end-date")
      titel: _jed("Change %s", _jed("Order"))
      buttonText: _jed("Save change")
    return false

  render: =>
    @linesContainer.html App.Render "borrow/views/order/grouped_and_merged_lines", App.Order.current.groupedAndMergedLines()
    @conflictsWarning.addClass("hidden") if App.Order.current.isAvailable()
