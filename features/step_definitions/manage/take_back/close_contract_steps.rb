When /^I open a take back(, not overdue)?( with at least an option handed over before today)?$/ do |arg1, arg2|
  reservations = Reservation.signed.where(inventory_pool_id: @current_user.inventory_pools.managed).order('RAND()')
  reservation = if arg1
                  reservations.detect { |c| c.user.reservations.signed.all? { |l| not l.late? } }
                elsif arg2
                  reservations.detect { |c| c.user.reservations.signed.any? { |l| l.is_a? OptionLine and l.start_date < Date.today } }
                else
                  reservations.first
                end
  expect(reservation).not_to be_nil
  @current_inventory_pool = reservation.inventory_pool
  @customer = reservation.user
  visit manage_take_back_path(@current_inventory_pool, @customer)
  expect(has_selector?('#take-back-view')).to be true
  @reservations_to_take_back = @customer.reservations.signed.where(inventory_pool_id: @current_inventory_pool)
end

When /^I select all reservations of an open contract$/ do
  within('#assign') do
    @reservations_to_take_back.each do |line|
      line.quantity.times do
        find('[data-barcode-scanner-target]').set line.item.inventory_code
        find('[data-barcode-scanner-target]').native.send_key :enter
      end
    end
  end
  expect(has_selector?('.line input[type=checkbox][data-select-line]')).to be true
  expect(all('.line input[type=checkbox][data-select-line]').all? {|x| x.checked? }).to be true
end

Then /^I see a summary of the things I selected for take back$/ do
  within('.modal') do
    @reservations_to_take_back.each do |line|
      has_content?(line.item.model.name)
    end
  end
end

When /^I click take back$/ do
  find('.button.green[data-take-back-selection]', text: _('Take Back Selection')).click
end

When /^I click take back inside the dialog$/ do
  within '.modal' do
    find('.button.green[data-take-back]', text: _('Take Back')).click
    expect(has_no_selector?('.button.green[data-take-back]', text: _('Take Back'))).to be true
  end
end

Then /^the contract is closed and all items are returned$/ do
  within '.modal' do
    find('.multibutton', text: _('Finish this take back'))
  end
  @reservations_to_take_back.each do |line|
    line.reload
    expect(line.item.in_stock?).to be true unless line.is_a? OptionLine
    expect(line.status).to eq :closed
  end
  expect(@customer.reservations.signed.where(inventory_pool_id: @current_inventory_pool)).to be_empty
end

Then /^the contract is not closed yet$/ do
  within '.modal' do
    find('.multibutton', text: _('Finish this take back'))
  end
  expect(@reservation.reload.status).to be :closed
  expect(@reservation.contract.reservations.signed.exists?).to be true
end

Then(/^not all reservations of that option are closed and returned$/) do
  expect(@reservation.contract.reservations.signed.where(option_id: @reservation.option_id, start_date: @reservation.start_date, end_date: @reservation.end_date).exists?).to be true
end
