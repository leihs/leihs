###
  
  Order

###

class window.App.Order extends Spine.Model

  @configure "Order", "id", "user_id", "inventory_pool_id", "status_const", "purpose"

  @hasMany "lines", "App.OrderLine", "order_id"

  isAvailable: => _.all @.lines().all(), (line) -> line["available?"]
