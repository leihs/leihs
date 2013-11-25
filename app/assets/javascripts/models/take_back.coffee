#= require ./visit
###
  
  TakeBack

###

class window.App.TakeBack extends App.Visit

  @configure "TakeBack", "id", "action", "date", "quantity", "status_const", "contract_line_ids"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @url: => "#{App.InventoryPool.url}/#{App.InventoryPool.current.id}/visits/take_backs"

  remind: => $.post "#{App.TakeBack.url()}/#{@id}/remind"