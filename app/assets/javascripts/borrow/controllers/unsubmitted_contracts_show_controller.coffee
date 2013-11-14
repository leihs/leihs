class window.App.UnsubmittedContractsShowController extends Spine.Controller

  elements:
    "#current-order-lines": "linesContainer"
    ".emboss.red": "conflictsWarning"

  events:
    "click [data-change-order-lines]": "changeContractLines"

  constructor: ->
    super
    new App.ModelsShowPropertiesController {el: "#properties"}
    new App.ModelsShowImagesController {el: "#images"}
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
    new App.ContractLinesChangeController
      modelId: target.data("model-id")
      lines: _.map target.data("line-ids"), (id) -> App.ContractLine.find id
      quantity: target.data("quantity")
      startDate: target.data("start-date")
      endDate: target.data("end-date")
      titel: _jed("Change %s", _jed("Order"))
      buttonText: _jed("Save change")
    return false

  render: =>
    @linesContainer.html App.Render "borrow/views/order/grouped_and_merged_lines", App.Contract.groupedAndMergedLines()
    @conflictsWarning.addClass("hidden") if _.all App.Contract.currents, (c) -> c.isAvailable()
