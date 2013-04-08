class Item

  @is_retirable = (item)->
    not item.current_borrower? and
    item.owner? and item.owner.id is currentInventoryPool.id
  
window.App.Item = Item
