###
  
  Current Item Location

###

class window.App.CurrentItemLocation extends Spine.Model

  @configure "CurrentItemLocation", "id", "location"

  @belongsTo "item", "App.Item", "id"
  
  @extend Spine.Model.Ajax

  @url = => "/manage/#{App.InventoryPool.current.id}/items/current_locations"