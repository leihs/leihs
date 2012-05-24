###

 InventoryPool
 
 This script provides functionalities for the inventory_pool
 
###

class InventoryPool
  
  constructor: (data)->
    for k,v of data
      @[k] = v
  
window.InventoryPool = InventoryPool