###
  
  Holiday

###

class window.App.Holiday extends Spine.Model

  @configure "Holiday"
  
  @belongsTo "inventory_pool", "App.InventoryPool", "inventory_pool_id"

  @extend Spine.Model.Ajax