# -*- encoding : utf-8 -*-


Then /^I see those items that are part of this take back$/ do
  @customer.visits.take_back.where(inventory_pool_id: @current_inventory_pool).first.reservations.each do |line|
    expect(find('.ui-autocomplete', match: :first).has_content? line.item.inventory_code).to be true
  end
end

When /^I assign something that is not part of this take back$/ do
  find('[data-add-contract-line]').set '_for_sure_this_is_not_part_of_the_take_back'
  find('[data-add-contract-line] + .addon').click
end

def check_printed_contract(window_handles, ip = nil, reservation = nil)
  while (page.driver.browser.window_handles - window_handles).empty? do end
  new_window = page.windows.find {|window|
    window if window.handle == (page.driver.browser.window_handles - window_handles).first
  }
  within_window new_window do
    find('.contract')
    expect(current_path).to eq manage_contract_path(ip, reservation.reload.contract) if ip and reservation
    expect(page.evaluate_script('window.printed')).to eq 1
  end
end
