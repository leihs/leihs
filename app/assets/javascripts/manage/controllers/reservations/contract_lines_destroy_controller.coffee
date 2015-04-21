class window.App.ReservationsDestroyController extends Spine.Controller

  events: 
    "click [data-destroy-line]": "destroyLine"
    "click [data-destroy-lines]": "destroyLines"
    "click [data-destroy-selected-lines]": "destroySelectedLines"

  destroyLine: (e)=> @destroyReservations $(e.currentTarget), [$(e.currentTarget).closest("[data-id]").data("id")]

  destroyLines: (e)=> @destroyReservations $(e.currentTarget), $(e.currentTarget).data("ids")

  destroySelectedLines: (e)=> @destroyReservations $(e.currentTarget), App.LineSelectionController.selected

  destroyReservations: (trigger, ids) =>
    App.LineSelectionController.selected = _.difference App.LineSelectionController.selected, ids
    App.Reservation.destroyMultiple ids
