class window.App.Borrow.ModelsShowController extends Spine.Controller

  events:
    "click [data-create-order-line]": "createOrderLine"

  constructor: ->
    super
    new App.Borrow.ModelsShowPropertiesController {el: "#properties"}
    new App.Borrow.ModelsShowImagesController {el: "#images"}

  createOrderLine: (e)=>
    do e.preventDefault
    new App.Borrow.OrderLinesCreateController 
      modelId: $(e.currentTarget).data("model-id")
      titel: _jed("Add to order")
      buttonText: _jed("Add")
    return false