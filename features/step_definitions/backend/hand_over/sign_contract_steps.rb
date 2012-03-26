When /^I open a hand over$/ do
  @ip = @user.managed_inventory_pools.first
  binding.pry
  @customer = @ip.users.all.select {|x| x.orders.size > 0}.first
  @order = @customer.order.first
  
  visit backend_inventory_pool_path @user.managed_inventory_pools.first
  find(".hand_over.line .button", :text => "Hand Over").click
  page.has_css?("#hand_over", :visible => true)
end

When /^I select some lines$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I see a summary of the things i selected for "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^the contract is signed$/ do
  pending # express the regexp above with the code you wish you had
end