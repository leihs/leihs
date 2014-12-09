###
  
  Visit

###

class window.App.Visit extends Spine.Model

  @configure "Visit", "id", "action", "date", "quantity", "status_const", "contract_line_ids"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @belongsTo "user", "App.User", "user_id"
  
  @include App.Modules.HasLines

  constructor: (data)->
    @_quantity = data.quantity
    super
    App.Visit.addRecord @ if not App.Visit.exists(@id)?

  lines: =>
    all: => (App.ContractLine.find id for id in @contract_line_ids)

  isOverdue: => moment().startOf("day").diff(moment(@date).startOf("day"), "days") >= 1

  quantity: => @_quantity

  @url: => "/manage/#{App.InventoryPool.current.id}/visits"

  remind: =>
    if @action == "take_back"
      $.post "#{App.Visit.url()}/#{@id}/remind"
