When /^I open the daily view$/ do
  @ip = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_path @ip
end

When /^I reject an order$/ do
  @order = @ip.orders.submitted.first
  find(".toggle .text").click
  first(".order .list .line[data-id='#{@order.id}']")
  first(".order .list .line[data-id='#{@order.id}'] .actions .trigger").click
  first(".order .list .line[data-id='#{@order.id}'] .actions .button", :text => _("Reject")).click
end

Then /^I see a summary of that order$/ do
  first(".dialog")
  unless @order.purpose.description.nil?
    first(".dialog .purpose").should have_content @order.purpose.description[0..25]
  end
end

Then /^I can write a reason why I reject that order$/ do
  first("#comment").set "you are not allowed to get these things"
end

When /^I reject the order$/ do
  first(".dialog .button[type=submit]").click
end

Then /^the order is rejected$/ do
  page.should_not have_selector(".order .list .line[data-id='#{@order.id}']")
  @order.reload.status_const.should == Order::REJECTED 
end

Then /^the counter of that list is updated/ do
  first(".order .list .line").first(:xpath, "../..").first(".badge").text.to_i.should == @ip.orders.submitted.count
end