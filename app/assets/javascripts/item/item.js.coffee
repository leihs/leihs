###

  Item

  This script provides functionalities for the Item
  
###

class Item
  
  @get_location: (item)->
    location = ""
    if (item.inventory_pool? and item.inventory_pool.id != current_inventory_pool) or item["in_stock?"]
      location = item.location
    else if item.current_borrower?
      location = "#{item.current_borrower.firstname} #{item.current_borrower.lastname}"
    if item.current_return_date?
      location = "#{location} (#{moment(item.current_return_date).format(i18n.date.L)})"
    location
        
window.Item = Item