class window.App.Borrow.CurrentOrderBasketController extends Spine.Controller

  elements:
    "#current-order-lines": "linesContainer"
    "#order-overview-button": "orderOverviewButton"

  constructor: ->
    super
    do @delegateEvents

  delegateEvents: =>
    App.Order.on "refresh", @render

  render: =>
    data = []
    for model_id, lines of _.groupBy App.Order.current.lines().all(), "model_id"
      data.push
        model: App.Model.find model_id
        quantity: _.reduce lines, ((mem, line)=> mem+line.quantity), 0
    data = _.sortBy data, (entry)-> entry.model.name
    @linesContainer.html App.Render "borrow/views/order/basket/line", data
    if _.size(data) > 0
      @orderOverviewButton.removeClass "hidden"
    else
      @orderOverviewButton.addClass "hidden"
