# encoding: UTF-8
# run with "rails runner -e production PATH_TO_THIS_FILE"
# WARNING: USE AT YOUR OWN RISK!!!

require_relative('logger')
# require('pry')

old_ip = InventoryPool.find_by_name('ZHdK-Inventar')
new_ip = InventoryPool.find_by_name('IT-Zentrum')
supply_category = 'IC-Technik/Software'

items_proc = proc do
  Item.where(owner: old_ip).select do |item|
    item.properties['anschaffungskategorie'] == 'IC-Technik/Software'
  end
end

log("Items owned by #{old_ip.name} BEFORE: #{Item.where(owner: old_ip).count}", :info, true)
log("Items owned by #{new_ip.name} BEFORE: #{Item.where(owner: new_ip).count}", :info, true)

log("number of items to move: #{items_proc.call.count}", :info, true)

items_proc.call.each do |item|
  begin
    item.update_attributes!(owner: new_ip)
  rescue => e
    log("error for #{item.inventory_code}: #{e.message}", :error, true)
  end
end

log("Items owned by #{old_ip.name} AFTER: #{Item.where(owner: old_ip).count}", :info, true)
log("Items owned by #{new_ip.name} AFTER: #{Item.where(owner: new_ip).count}", :info, true)
