class window.App.ModelsShowController extends Spine.Controller

  events:
    "click [data-create-order-line]": "createReservation"

  constructor: ->
    super
    new App.ModelsShowPropertiesController {el: "#properties"}
    new App.ModelsShowImagesController {el: "#images"}

  createReservation: (e)=>
    do e.preventDefault
    new App.ReservationsCreateController
      modelId: $(e.currentTarget).data("model-id")
      titel: _jed("Add to order")
      buttonText: _jed("Add")
    return false