When /^I open a take back$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.all.select {|x| x.contracts.signed.size > 0}.first
  @contract = @customer.contracts.signed.first
  visit backend_inventory_pool_user_take_back_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
end

When /^I select all lines of an open contract$/ do
  @contract.items.each do |item|
    @line = find("li.name",:text => item.model.name).find(:xpath, "./../..")
    @line.find("input[type=checkbox]").click
  end
end

When /^I click take back$/ do
  find("#take_back_button").click
end

Then /^I see a summary of the things I selected for take back$/ do
  @contract.items.each do |item|
    find(".dialog").should have_content(item.model.name)
  end
end

When /^I click take back inside the dialog$/ do
  find(".dialog button[type=submit]").click
  wait_until { ! page.has_css?(".dialog")}
end

Then /^the contract is closed and all items are returned$/ do
  @contract.reload.status_const.should == Contract::CLOSED
  @contract.items.each do |item|
    item.in_stock?.should be_true
  end
end