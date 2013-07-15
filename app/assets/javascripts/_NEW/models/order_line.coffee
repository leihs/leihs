###
  
  OrderLine

###

class window.App.OrderLine extends Spine.Model

  @configure "OrderLine", "id", "model_id", "order_id", "inventory_pool_id", "quantity", "start_date", "end_date", "purpose_id"

  @extend Spine.Model.Ajax

  @belongsTo "order", "App.Order", "order_id"
  @belongsTo "model", "App.Model", "model_id"