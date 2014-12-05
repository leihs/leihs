When /^I open the daily view$/ do
  @current_inventory_pool = @current_inventory_pool || @current_user.managed_inventory_pools.sample
  visit manage_daily_view_path @current_inventory_pool
end

When /^I reject a contract$/ do
  @contract = @current_inventory_pool.contracts.submitted.sample

  step %Q(I uncheck the "No verification required" button)

  @daily_view_line = find(".line[data-id='#{@contract.id}']")
  within @daily_view_line do
    find(".dropdown-toggle").click
    find(".red[data-order-reject]", text: _("Reject")).click
  end
end

When /^I reject this contract$/ do
  find("#daily-navigation button[data-order-reject][data-id='#{@contract.id}']").click
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

When /^I confirm the contract rejection$/ do
  within(".modal") do
    find(".button.red[type=submit]").click
  end
  step "the modal is closed"
end

Then /^the contract is rejected$/ do
  if @daily_view_line
    within @daily_view_line do
      find(".button", match: :first, text: _("Rejected"))
    end
  end
  expect(@contract.reload.status).to eq :rejected
end

Then(/^I am redirected to the daily view$/) do
  expect(current_path).to eq manage_daily_view_path(@current_inventory_pool)
end
