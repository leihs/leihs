class window.App.ReservationsEditController extends Spine.Controller

  events:
    "click [data-edit-lines]": "editLines"

  editLines: (e)=>
    trigger = $ e.currentTarget
    selectedLines = trigger.data("edit-lines") == "selected-lines" 
    ids = if selectedLines then App.LineSelectionController.selected else trigger.data "ids"
    reservations = (App.Reservation.find id for id in ids)
    mergedLines = App.Modules.HasLines.mergeLinesByModel reservations
    quantity = if selectedLines 
        null 
      else 
        _.reduce mergedLines, (mem, l)-> 
          mem + (if l.sublines? then _.reduce(l.sublines, ((mem, l)-> mem+l.quantity), 0) else l.quantity)
        , 0
    models = _.unique _.map(_.filter(mergedLines, (l)->l.model_id?), (l)-> l.model()), false, (m) -> m.id
    new App.ReservationsChangeController
      mergedLines: mergedLines
      lines: reservations
      user: @user
      models: models
      quantity: quantity
      contract: @contract
      startDateDisabled: @startDateDisabled
      quantityDisabled: @quantityDisabled