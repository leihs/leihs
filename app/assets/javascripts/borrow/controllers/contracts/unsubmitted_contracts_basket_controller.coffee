class window.App.UnsubmittedContractsBasketController extends Spine.Controller

  elements:
    "#current-order-lines": "linesContainer"
    "#order-overview-button": "orderOverviewButton"

  constructor: ->
    super
    @timeoutCountdown = new App.TimeoutCountdownController
      el: @el.find("#timeout-countdown")
      template: "borrow/views/order/basket/timeout_countdown"
      refreshTarget: @el.find("#timeout-countdown-refresh")
    do @delegateEvents

  delegateEvents: =>
    App.Contract.on "refresh", @render

  render: =>
    data = []
    all_lines = _.flatten(_.map App.Contract.currents, (c)-> c.lines().all())
    for model_id, lines of _.groupBy all_lines, "model_id"
      data.push
        model: App.Model.find model_id
        quantity: _.reduce lines, ((mem, line)=> mem+line.quantity), 0
    data = _.sortBy data, (entry)-> entry.model.name()
    @linesContainer.html App.Render "borrow/views/order/basket/line", data
    if _.size(data) > 0
      @orderOverviewButton.removeClass "hidden"
    else
      @orderOverviewButton.addClass "hidden"