###
  
  ContractLine

###

class window.App.ContractLine extends Spine.Model

  @configure "ContractLine", "id", "model_id", "contract_id", "inventory_pool_id", "quantity", "start_date", "end_date", "purpose_id", "available?"

  @extend Spine.Model.Ajax

  @belongsTo "contract", "App.Contract", "contract_id"
  @belongsTo "model", "App.Model", "model_id"
  @belongsTo "inventory_pool", "App.InventoryPool", "inventory_pool_id"
