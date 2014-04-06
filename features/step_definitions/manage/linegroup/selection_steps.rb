When /^I open a take back, hand over or I edit a contract$/ do
  @ip = @current_user.managed_inventory_pools.first
  possible_types = ["take_back", "hand_over", "contract"]
  type = possible_types.sample
  case type
    when "take_back"
      @customer = @ip.users.detect {|x| x.contracts.signed.size > 0}
      visit manage_take_back_path(@ip, @customer)
    when "hand_over"
      @customer = @ip.users.detect {|x| x.contracts.approved.size > 0}
      visit manage_hand_over_path(@ip, @customer)
    when "contract"
      @customer = @ip.users.detect {|x| x.contracts.submitted.size > 0}
      @entity = @customer.contracts.submitted.first
      visit manage_edit_contract_path(@ip, @entity)
  end
end

When /^I select all lines of an linegroup$/ do
  find("#lines")
  @linegroup = find("#lines [data-selected-lines-container]", match: :first)
  @linegroup.all(".line").each do |line|
    line.first("input[type=checkbox][data-select-line]").click
  end
end

Then /^the linegroup is selected$/ do
  @linegroup.find("input[type=checkbox][data-select-lines]").checked?.should be_true
end

Then /^the count matches the amount of selected lines$/ do
  all("input[type=checkbox][data-select-line]").select{|x| x.checked? }.size.should == find("#line-selection-counter").text.to_i
end

When /^I select the linegroup$/ do
  @linegroup = find("#lines [data-selected-lines-container]", match: :first)
  @linegroup.find("input[type=checkbox][data-select-lines]").checked?.should be_false
  @linegroup.find("input[type=checkbox][data-select-lines]").click
  @linegroup.find("input[type=checkbox][data-select-lines]").checked?.should be_true
end

Then /^all lines of that linegroup are selected$/ do
  @linegroup.all(".line").each do |line|
    line.first("input[type=checkbox][data-select-line]").checked?.should be_true
  end
end
