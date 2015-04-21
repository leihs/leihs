When /^I open a take back(, not overdue)?( with at least an option handed over before today)?$/ do |arg1, arg2|
  contracts = ReservationsBundle.signed.where(inventory_pool_id: @current_user.inventory_pools.managed).order("RAND()")
  contract = if arg1
               contracts.detect {|c| not c.lines.any? {|l| l.end_date < Date.today} }
             elsif arg2
               contracts.detect {|c| c.lines.any? {|l| l.is_a? OptionLine and l.start_date < Date.today} }
             else
               contracts.first
             end
  expect(contract).not_to be_nil
  @current_inventory_pool = contract.inventory_pool
  @customer = contract.user
  visit manage_take_back_path(@current_inventory_pool, @customer)
  expect(has_selector?("#take-back-view")).to be true
  @reservations_to_take_back = @customer.reservations.signed.where(inventory_pool_id: @current_inventory_pool)
end

When /^I select all lines of an open contract$/ do
  within("#assign") do
    @reservations_to_take_back.each do |line|
      line.quantity.times do
        find("[data-barcode-scanner-target]").set line.item.inventory_code
        find("[data-barcode-scanner-target]").native.send_key :enter
      end
    end
  end
  expect(has_selector?(".line input[type=checkbox][data-select-line]")).to be true
  expect(all(".line input[type=checkbox][data-select-line]").all? {|x| x.checked? }).to be true
end

Then /^I see a summary of the things I selected for take back$/ do
  within(".modal") do
    @reservations_to_take_back.each do |line|
      has_content?(line.item.model.name)
    end
  end
end

When /^I click take back$/ do
  find(".button.green[data-take-back-selection]").click
end

When /^I click take back inside the dialog$/ do
  find(".modal .button.green[data-take-back]").click
  expect(has_no_selector?(".modal .button.green[data-take-back]")).to be true
end

Then /^the contract is closed and all items are returned$/ do
  find(".modal .multibutton", text: _("Finish this take back"))
  @reservations_to_take_back.each do |line|
    line.reload
    expect(line.item.in_stock?).to be true unless line.is_a? OptionLine
    expect(line.status).to eq :closed
  end
  expect(@customer.reservations.signed.where(inventory_pool_id: @current_inventory_pool)).to be_empty
end
