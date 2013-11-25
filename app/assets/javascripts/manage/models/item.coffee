window.App.Item.url = => "/manage/#{App.InventoryPool.current.id}/items"

window.App.Item::updateWithFieldData = (data) -> 
  $.ajax 
    url: @url()
    data: data
    type: "PUT"

window.App.Item::inspect = (data) -> 
  for k,v of data
    @[k] = v
  App.Item.addRecord(@)
  App.Item.trigger "refresh"
  $.post "#{window.App.Item.url()}/#{@id}/inspect", data