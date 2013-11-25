###
  
  Workday

###

class window.App.Workday extends Spine.Model

  @configure "Workday"
  
  @belongsTo "inventory_pool", "App.InventoryPool", "inventory_pool_id"

  @extend Spine.Model.Ajax

  closedDays: => 
    days = []
    days.push 0 unless @sunday
    days.push 1 unless @monday
    days.push 2 unless @tuesday
    days.push 3 unless @wednesday
    days.push 4 unless @thursday
    days.push 5 unless @friday
    days.push 6 unless @saturday
    days