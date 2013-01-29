When /^I open a take back$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.detect {|x| x.contracts.signed.size > 0}
  @contract = @customer.contracts.signed.first
  visit backend_inventory_pool_user_take_back_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
end

When /^I select all lines of an open contract$/ do
  all(".line", :text => /(Contract #{@contract.id}|Vertrag #{@contract.id})/).each do |line|
    line.find("input[type=checkbox]").click unless line.find("input[type=checkbox]").checked?
  end
end

When /^I click take back$/ do
  find("#take_back_button").click
end

Then /^I see a summary of the things I selected for take back$/ do
  wait_until{ find(".dialog") }
  @contract.items.each do |item|
    find(".dialog").should have_content(item.model.name)
  end
end

When /^I click take back inside the dialog$/ do
  find(".dialog button[type=submit]").click
  wait_until { all(".dialog.take_back").size == 0 }
end

Then /^the contract is closed and all items are returned$/ do
  wait_until { find(".dialog .documents") }
  wait_until { @contract.reload.status_const == Contract::CLOSED }
  @contract.items.each do |item|
    item.in_stock?.should be_true
  end
end