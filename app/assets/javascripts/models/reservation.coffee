###
  
  Reservation

###

class window.App.Reservation extends Spine.Model

  @configure "Reservation", "id", "inventory_pool_id", "user_id", "delegated_user_id", "status", "contract_id", "model_id", "option_id", "purpose_id", "quantity", "start_date", "end_date", "item_id"

  @belongsTo "contract", "App.Contract", "contract_id"
  @belongsTo "inventory_pool", "App.InventoryPool", "inventory_pool_id"
  @belongsTo "user", "App.User", "user_id"
  @belongsTo "delegatedUser", "App.User", "delegated_user_id"
  @belongsTo "model", "App.Model", "model_id"
  @belongsTo "option", "App.Option", "option_id"
  @belongsTo "purpose", "App.Purpose", "purpose_id"
  @belongsTo "item", "App.Item", "item_id"

  @extend Spine.Model.Ajax

  @url: "/reservations"

  model: ->
    if @model_id? 
      model = App.Model.exists(@model_id) ? App.Software.exists(@model_id)
      model ? throw new Error("Could not find model or software with #{@model_id}")
    else 
      App.Option.find @option_id

  item: ->
    if @item_id
      item = App.Item.exists(@item_id) ? App.License.exists(@item_id)
      item ? throw new Error("Could not find item or license with #{@item_id}")

  inventoryCode: ->
    if @item()
      @item().inventory_code
    else if @option()
      @option().inventory_code
