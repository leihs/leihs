###
  
  ContractLine

###

class window.App.ContractLine extends Spine.Model

  @configure "ContractLine", "id", "inventory_pool_id", "contract_id", "model_id", "option_id", "purpose_id", "quantity", "start_date", "end_date", "item_id"

  @belongsTo "contract", "App.Contract", "contract_id"
  @belongsTo "inventory_pool", "App.InventoryPool", "inventory_pool_id"
  @belongsTo "model", "App.Model", "model_id"
  @belongsTo "option", "App.Option", "option_id"
  @belongsTo "purpose", "App.Purpose", "purpose_id"
  @belongsTo "item", "App.Item", "item_id"

  @extend Spine.Model.Ajax

  @url: "/contract_lines"

  model: ->
    if @model_id? 
      App.Model.find @model_id
    else 
      App.Option.find @option_id

  inventoryCode: ->
    if @item()
      @item().inventory_code
    else if @option()
      @option().inventory_code

  user: -> @contract().user()