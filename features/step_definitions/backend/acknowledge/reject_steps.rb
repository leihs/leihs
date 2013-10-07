When /^I open the daily view$/ do
  @ip = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_path @ip
end

When /^I reject a contract$/ do
  @contract = @ip.contracts.submitted.first
  find(".toggle .text").click
  first(".order .list .line[data-id='#{@contract.id}']")
  first(".order .list .line[data-id='#{@contract.id}'] .actions .trigger").click
  first(".order .list .line[data-id='#{@contract.id}'] .actions .button", :text => _("Reject")).click
end

Then /^I see a summary of that contract$/ do
  first(".dialog")
  unless @contract.purpose.description.nil?
    first(".dialog .purpose").should have_content @contract.purpose.description[0..25]
  end
end

Then /^I can write a reason why I reject that contract$/ do
  first("#comment").set "you are not allowed to get these things"
end

When /^I reject the contract$/ do
  first(".dialog .button[type=submit]").click
end

Then /^the contract is rejected$/ do
  page.should_not have_selector(".order .list .line[data-id='#{@contract.id}']")
  @contract.reload.status.should == :rejected
end

Then /^the counter of that list is updated/ do
  first(".order .list .line").first(:xpath, "../..").first(".badge").text.to_i.should == @ip.contracts.submitted.count
end
