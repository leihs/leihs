When /^I open a take back, hand over or I edit a contract$/ do
  @ip = @current_user.managed_inventory_pools.first
  possible_types = ["take_back", "hand_over", "contract"]
  type = possible_types.shuffle.first
  case type
    when "take_back"
      @customer = @ip.users.detect {|x| x.contracts.signed.size > 0}
      visit backend_inventory_pool_user_take_back_path(@ip, @customer)
    when "hand_over"
      @customer = @ip.users.detect {|x| x.contracts.approved.size > 0}
      visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
    when "contract"
      @customer = @ip.users.detect {|x| x.contracts.submitted.size > 0}
      @entity = @customer.contracts.submitted.first
      visit backend_inventory_pool_acknowledge_path(@ip, @entity)
  end
end

When /^I select all lines of an linegroup$/ do
  @linegroup = find(".linegroup", match: :first)
  @linegroup.all(".line").each do |line|
    line.first("input[type=checkbox]").click
  end
end

Then /^the linegroup is selected$/ do
  @linegroup.first(".select_group").checked?.should be_true
end

Then /^the count matches the amount of selected lines$/ do
  count = first("#selection_actions .count").text.gsub(/[()]/, "").to_i
  page.evaluate_script(%Q{ $(".line input:checked").length }).should == count
end

When /^I select the linegroup$/ do
  @linegroup = find(".linegroup", match: :first)
  @linegroup.first(".dates input").click
end

Then /^all lines of that linegroup are selected$/ do
  @linegroup.all(".line").each do |line|
    line.first(".select input[type=checkbox]").checked?.should be_true
  end
end
