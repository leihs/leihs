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
  @ip = contract.inventory_pool
  @customer = contract.user
  visit manage_take_back_path(@ip, @customer)
  page.has_css?("#take_back", :visible => true)
  @contract_lines_to_take_back = @customer.contract_lines.to_take_back.joins(:contract).where(contracts: {inventory_pool_id: @ip})
end

When /^I select all lines of an open contract$/ do
  within("#assign") do
    @contract_lines_to_take_back.each do |line|
      find("[data-barcode-scanner-target]").set line.item.inventory_code
      sleep(0.11)
      find("[data-barcode-scanner-target]").native.send_key :enter
    end
  end
  page.should have_selector(".line input[type=checkbox][data-select-line]")
  all(".line input[type=checkbox][data-select-line]").all? {|x| x.checked? }.should be_true
end

When /^I click take back$/ do
  find(".button.green[data-take-back-selection]").click
end

Then /^I see a summary of the things I selected for take back$/ do
  within find(".modal") do
    @contract_lines_to_take_back.each do |line|
      has_content?(line.item.model.name)
    end
  end
end

When /^I click take back inside the dialog$/ do
  find(".modal .button.green[data-take-back]").click
  page.has_no_selector?(".modal .button.green[data-take-back]")
end

Then /^the contract is closed and all items are returned$/ do
  find(".modal .multibutton", text: _("Finish this take back"))
  @contract_lines_to_take_back.each do |line|
    line.reload
    line.item.in_stock?.should be_true unless line.is_a? OptionLine
    line.contract.status.should == :closed
  end
  @customer.contract_lines.to_take_back.joins(:contract).where(contracts: {inventory_pool_id: @ip}).should be_empty
end
