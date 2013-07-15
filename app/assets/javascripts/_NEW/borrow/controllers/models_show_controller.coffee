class window.App.Borrow.ModelsShowController extends Spine.Controller

  constructor: ->
    super
    new App.Borrow.ModelsShowPropertiesController {el: "#properties"}
    new App.Borrow.ModelsShowImagesController {el: "#images"}
    do @delegateEvents

  delegateEvents: =>
    @el.on "click", "[data-add-to-order]", (e)=> 
      do e.preventDefault
      new App.Borrow.OrderLinesCreateController 
        modelId: $(e.currentTarget).data("add-to-order")
      return false