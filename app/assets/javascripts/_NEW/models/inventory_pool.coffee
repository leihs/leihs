###
  
  InventoryPool

###

class window.App.InventoryPool extends Spine.Model

  @configure "InventoryPool", "id", "name"
  
  @hasMany "models", "App.Model", "inventory_pool_id"

  @extend Spine.Model.Ajax

  @url: => "/availability"