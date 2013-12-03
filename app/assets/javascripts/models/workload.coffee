###
  
  Workload

###

class window.App.Workload extends Spine.Model

  @configure "Workload", "data"

  @extend Spine.Model.Ajax

  @url: => "#{App.InventoryPool.url}/#{App.InventoryPool.current.id}/workload"  
