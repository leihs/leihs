class window.App.ModelsShowController extends Spine.Controller

  events:
    "click [data-create-order-line]": "createContractLine"

  constructor: ->
    super
    new App.ModelsShowPropertiesController {el: "#properties"}
    new App.ModelsShowImagesController {el: "#images"}

  createContractLine: (e)=>
    do e.preventDefault
    new App.ContractLinesCreateController
      modelId: $(e.currentTarget).data("model-id")
      titel: _jed("Add to order")
      buttonText: _jed("Add")
    return false