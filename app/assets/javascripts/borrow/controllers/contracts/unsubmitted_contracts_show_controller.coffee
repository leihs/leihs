class window.App.UnsubmittedContractsShowController extends Spine.Controller

  elements:
    "#current-order-lines": "linesContainer"
    ".emboss.red": "conflictsWarning"

  events:
    "click [data-change-order-lines]": "changeContractLines"

  constructor: ->
    super
    unless App.Contract.timedOut
      @timeoutCountdown = new App.TimeoutCountdownController
        el: @el.find("#timeout-countdown")
        refreshTarget: @el.find("#timeout-countdown")
    
  delegateEvents: =>
    super
    App.Contract.bind "refresh", (data)=>
      do @render

  changeContractLines: (e)=>
    do e.preventDefault
    target = $(e.currentTarget)
    lines = _.map target.data("ids"), (id) -> App.ContractLine.find id
    quantity = _.reduce lines, ((mem, l)-> mem + l.quantity), 0
    new App.ContractLinesChangeController
      modelId: target.data("model-id")
      lines: lines
      quantity: quantity
      startDate: target.data("start-date")
      endDate: target.data("end-date")
      titel: _jed("Change %s", _jed("Order"))
      buttonText: _jed("Save change")
      withoutLines: true
    return false

  render: =>
    lines = _.flatten(_.map App.Contract.currents, (c)-> c.lines().all())
    @linesContainer.html App.Render "borrow/views/order/grouped_and_merged_lines", App.Modules.HasLines.groupByDateAndPool(lines, true)
    @conflictsWarning.addClass("hidden") if _.all lines, (l) -> l.available()
