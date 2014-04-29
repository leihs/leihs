_.invoke [window.App.Item, window.App.License], -> this.url = -> "/manage/#{App.InventoryPool.current.id}/items"

_.invoke [window.App.Item, window.App.License], -> this::updateWithFieldData = (data) -> 
  $.ajax 
    url: @url()
    data: data
    type: "PUT"

_.invoke [window.App.Item, window.App.License], -> this::inspect = (data) -> 
  for k,v of data
    @[k] = v
  App.Item.addRecord(@)
  App.Item.trigger "refresh"
  $.post "#{window.App.Item.url()}/#{@id}/inspect", data
