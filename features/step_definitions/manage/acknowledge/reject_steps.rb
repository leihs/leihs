When /^I open the daily view$/ do
  @ip = @current_user.managed_inventory_pools.sample
  visit manage_daily_view_path @ip
end

When /^I reject a contract$/ do
  @contract = @ip.contracts.submitted.sample
  find("[data-collapsed-toggle='#open-orders']").click unless all("[data-collapsed-toggle='#open-orders']").empty?
  within("#open-orders .line[data-id='#{@contract.id}']") do
    find(".line-actions .multibutton .dropdown-holder").hover
    find(".dropdown-item[data-order-reject]", :text => _("Reject")).click
  end
end

Then /^I see a summary of that contract$/ do
  within(".modal") do
    unless @contract.purpose.description.nil?
      find("p", text: @contract.purpose.description[0..25])
    end
  end
end

Then /^I can write a reason why I reject that contract$/ do
  find("#rejection-comment").set "you are not allowed to get these things"
end

When /^I reject the contract$/ do
  find(".modal .button.red[type=submit]").click
  page.has_no_selector?(".modal").should be_true
end

Then /^the contract is rejected$/ do
  find("#open-orders .line[data-id='#{@contract.id}'] .button", match: :first, text: _("Rejected"))
  @contract.reload.status.should == :rejected
end
