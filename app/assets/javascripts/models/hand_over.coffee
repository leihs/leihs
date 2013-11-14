#= require ./visit
###
  
  HandOver

###

class window.App.HandOver extends App.Visit

  @configure "HandOver", "id", "action", "date", "quantity", "status_const", "contract_line_ids"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @url: => "#{App.InventoryPool.url}/#{App.InventoryPool.current.id}/visits/hand_overs"