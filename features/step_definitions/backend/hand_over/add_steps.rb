When /^I add an item to the hand over by providing an inventory code and a date range$/ do
  @inventory_code = @user.managed_inventory_pools.first.items.in_stock.first.inventory_code
  find("#quick_add").set @inventory_code
  find("#add_item .button").click
  wait_until { all("#add_item .loading", :visible => true).size == 0 }
end

Then /^the item is added to the hand over for the provided date range and the inventory code is already assigend$/ do
  @customer.contracts.unsigned.last.items.include?(Item.find_by_inventory_code(@inventory_code)).should == true
  assigned_inventory_codes = all(".line .inventory_code input[type=text]").map(&:value)
  assigned_inventory_codes.should include(@inventory_code)
end

When /^I add an option to the hand over by providing an inventory code and a date range$/ do
  @inventory_code = @user.managed_inventory_pools.first.options.first.inventory_code
  find("#quick_add").set @inventory_code
  find("#add_item .button").click
  wait_until { all("#add_item .loading", :visible => true).size == 0 }
end

Then /^the option is added to the hand over for the provided date range$/ do
  @customer.contracts.unsigned.last.options.include?(Option.find_by_inventory_code(@inventory_code))
  find(".option_line .inventory_code", :text => @inventory_code)
end

When /^I add an option to the hand over which is already existing in the selected date range by providing an inventory code$/ do
  step 'I add an option to the hand over by providing an inventory code and a date range'
  step 'the option is added to the hand over for the provided date range'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Then /^the existing option quantity is increased$/ do
  matching_option_lines = @customer.contracts.unsigned.last.option_lines.select{|x| x.option.inventory_code == @inventory_code}
  matching_option_lines.size.should == 1
  all(".option_line.line", :text => @inventory_code).size.should == 1
  matching_option_lines.first.quantity == 2
  all(".option_line.line", :text => @inventory_code).first.find(".quantity input").value.to_i.should == 2
end
