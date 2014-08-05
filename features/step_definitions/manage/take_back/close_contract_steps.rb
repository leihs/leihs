When /^I open a take back(, not overdue)?( with at least an option handed over before today)?$/ do |arg1, arg2|
  contracts = Contract.signed.where(inventory_pool_id: @current_user.managed_inventory_pools)
  contract = if arg1
               contracts.select {|c| not c.lines.any? {|l| l.end_date < Date.today} }
             elsif arg2
               contracts.select {|c| c.lines.any? {|l| l.is_a? OptionLine and l.start_date < Date.today} }
             else
               contracts
             end.sample
  raise "No contract found" unless contract
  @current_inventory_pool = contract.inventory_pool
  @customer = contract.user
  visit manage_take_back_path(@current_inventory_pool, @customer)
  expect(has_selector?("#take-back-view")).to be true
  @contract_lines_to_take_back = @customer.contract_lines.to_take_back.joins(:contract).where(contracts: {inventory_pool_id: @current_inventory_pool})
end

When /^I select all lines of an open contract$/ do
  within("#assign") do
    @contract_lines_to_take_back.each do |line|
      line.quantity.times do
        find("[data-barcode-scanner-target]").set line.item.inventory_code
        find("[data-barcode-scanner-target]").native.send_key :enter
      end
    end
  end
  expect(has_selector?(".line input[type=checkbox][data-select-line]")).to be true
  expect(all(".line input[type=checkbox][data-select-line]").all? {|x| x.checked? }).to be true
end

When /^I click take back$/ do
  find(".button.green[data-take-back-selection]").click
end

Then /^I see a summary of the things I selected for take back$/ do
  within(".modal") do
    @contract_lines_to_take_back.each do |line|
      has_content?(line.item.model.name)
    end
  end
end

When /^I click take back inside the dialog$/ do
  find(".modal .button.green[data-take-back]").click
  expect(has_no_selector?(".modal .button.green[data-take-back]")).to be true
end

Then /^the contract is closed and all items are returned$/ do
  find(".modal .multibutton", text: _("Finish this take back"))
  @contract_lines_to_take_back.each do |line|
    line.reload
    expect(line.item.in_stock?).to be true unless line.is_a? OptionLine
    expect(line.contract.status).to eq :closed
  end
  expect(@customer.contract_lines.to_take_back.joins(:contract).where(contracts: {inventory_pool_id: @current_inventory_pool}).empty?).to be true
end
