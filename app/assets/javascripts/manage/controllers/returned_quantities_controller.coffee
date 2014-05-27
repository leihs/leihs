class window.App.ReturnedQuantityController extends Spine.Controller

  returnedQuantities: []

  restore: =>
    _.each @returnedQuantities, (inputField) =>
      @el.find(".line[data-id='#{inputField["id"]}'] [data-quantity-returned]")?.val inputField["quantity"]

  updateWith: (id, quantity) =>
    @returnedQuantities = _.reject @returnedQuantities, (el) -> el["id"] == id
    @returnedQuantities.push {id: id, quantity: quantity}
