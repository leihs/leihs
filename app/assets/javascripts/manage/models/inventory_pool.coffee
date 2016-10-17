window.App.InventoryPool.url = "/manage"

window.App.InventoryPool::isOwnerOrResponsibleFor = (item) ->
  this.id == item.owner_id or this.id == item.inventory_pool_id
