class window.App.SwapModelController extends Spine.Controller

  events: 
    "click [data-swap-model]": "exploreModels"

  swapModel: (model, startDate, endDate)=>
    $.post "/manage/#{App.InventoryPool.current.id}/reservations/swap_model",
      line_ids: (line.id for line in @reservations)
      model_id: model.id
    , (data)->
      for line in data
        App.Reservation.update line.id, line

  exploreModels: (e)=>
    @reservations = if $(e.currentTarget).closest("[data-ids]").length
                      _.map $(e.currentTarget).closest("[data-ids]").data("ids"), (id)-> App.Reservation.find id
                    else
                      [App.Reservation.find $(e.currentTarget).closest("[data-id]").data("id")]
    reservation = @reservations[0]
    new App.ReservationsExplorativeAddController
      contract: reservation.contract()
      startDate: reservation.start_date
      endDate: reservation.end_date
      addModel: @swapModel

