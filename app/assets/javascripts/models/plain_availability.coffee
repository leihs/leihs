###
  
  PlainAvailability

  just quantity for a given range

###

class window.App.PlainAvailability extends Spine.Model

  @configure "PlainAvailability", "inventory_pool_id", "model_id", "quantity"
  
  @belongsTo "inventory_pool", "App.InventoryPool", "inventory_pool_id"
  @belongsTo "model", "App.Model", "model_id"

  @extend Spine.Model.Ajax