When /^I edit an order for acknowledgment$/ do
  visit backend_inventory_pool_acknowledge_path(@user.managed_inventory_pools.first, 
                                                @user.managed_inventory_pools.first.orders.first)
end

When /^I add an item through the quick add item field$/ do
  fill_in("quick_add", :with =>  @user.managed_inventory_pools.first.items.first.serial_number)
  find("#add_item .add_item.button").click
end

Then /^the item is added to the order$/ do
  pending # express the regexp above with the code you wish you had
end

