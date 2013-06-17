window.App.Model.url = => "/borrow/models"

window.App.Model::availableQuantityForInventoryPools = (inventory_pool_ids)->
  return -1 unless @availabilities().all().length
  _.reduce @availabilities().all(), (memory, av)->
    if _.include(inventory_pool_ids, av.inventory_pool_id)
      memory + av.quantity 
    else
      0
  , 0