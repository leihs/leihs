###
  
  Visit

###

class window.App.Visit extends Spine.Model

  @configure "Visit", "id", "date", "quantity", "status", "reservation_ids"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @belongsTo "user", "App.User", "user_id"
  
  @include App.Modules.HasLines

  constructor: (data)->
    @_quantity = data.quantity
    super
    App.Visit.addRecord @ if not App.Visit.exists(@id)?

  reservations: =>
    all: => (App.Reservation.find id for id in @reservation_ids)

  isOverdue: => moment().startOf("day").diff(moment(@date).startOf("day"), "days") >= 1

  quantity: => @_quantity

  @url: => "/manage/#{App.InventoryPool.current.id}/visits"

  remind: =>
    if @status == "signed"
      $.post "#{App.Visit.url()}/#{@id}/remind"
