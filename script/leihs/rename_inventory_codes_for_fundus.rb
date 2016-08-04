# run with "rails runner -e production PATH_TO_THIS_FILE"
# WARNING: USE AT YOUR OWN RISK!!!

require_relative('logger')

log("renaming...", :info, true)

ip = InventoryPool.find_by_name('Fundus-TDK')
items_to_rename = Item.where(inventory_pool: ip).select { |i| i.inventory_code.match /FUN\d{4}/ }

log("number of inventory codes to rename: #{items_to_rename.count}")

items_to_rename.each do |item|
  item.update_column(:inventory_code,
                     item.inventory_code.gsub(/FUN/, 'F'))
end

items_not_renamed = Item.where(inventory_pool: ip).select { |i| i.inventory_code.match /FUN\d{4}/ }
if items_not_renamed.count > 0
  log("some items could not be renamed. see /tmp/rails_script.txt")
  items_not_renamed.each do |item|
    log("item #{item.inventory_code} not renamed")
  end
else
  log("OK", :info, true)
end
