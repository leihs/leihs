###
  
  InventoryPool

###

class window.App.InventoryPool extends Spine.Model

  @configure "InventoryPool", "id", "name"
  
  @hasMany "availabilities", "App.Availability", "inventory_pool_id"
  @hasMany "models", "App.Model", "inventory_pool_id"
  @hasMany "holidays", "App.Holiday", "inventory_pool_id"
  @hasOne "workday", "App.Workday", "inventory_pool_id"

  @extend Spine.Model.Ajax

  @url: => "/inventory_pools"