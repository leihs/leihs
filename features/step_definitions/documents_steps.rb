# -*- encoding : utf-8 -*-

When(/^I click on "([^"]*)" underneath my username$/) do |arg|
  #step "ich über meinen Namen fahre"
  step 'I hover over my name'
  find("a[href='#{borrow_user_documents_path}']").click
end

Then(/^my contracts are ordered by the earliest time window$/) do
  dates = all('div.line-col', text: /\d{2}.\d{2}.\d{4}\s\-\s\d{2}.\d{2}.\d{4}/).map {|x| Date.parse(x.text.split.first) }
  expect(dates.sort).to eq dates
end

Then(/^I see the following information for each contract:$/) do |table|
  contracts = @current_user.reservations_bundles.signed_or_closed.sort {|a,b| b.time_window_min <=> a.time_window_min}
  contracts.each do |contract|
    within(".line[data-id='#{contract.id}']") do
      table.raw.flatten.each do |s|
        case s
          when 'Contract number'
            expect(has_content?(contract.id)).to be true
          when 'Time window with its start and end'
            expect(has_content?(contract.time_window_min.strftime('%d/%m/%Y'))).to be true
            expect(has_content?(contract.time_window_max.strftime('%d/%m/%Y'))).to be true
            expect(has_content?((contract.time_window_max - contract.time_window_min).to_i.abs + 1)).to be true
          when 'Inventory pool'
            expect(has_content?(contract.inventory_pool.shortname)).to be true
          when 'Purpose'
            expect(has_content?(contract.purpose)).to be true
          when 'Status'
            expect(has_content?(_('Open'))).to be true if contract.status == :signed
          when 'Link to the contract'
            expect(has_selector?("a[href='#{borrow_user_contract_path(contract.id)}']", text: _('Contract'))).to be true
          when 'Link to the value list'
            find("a[href='#{borrow_user_contract_path(contract.id)}'] + .dropdown-holder > .dropdown-toggle").click
            expect(has_selector?("a[href='#{borrow_user_value_list_path(contract.id)}']")).to be true
            find("a[href='#{borrow_user_contract_path(contract.id)}']").click # release the previous click
          else
            raise 'unkown section'
        end
      end
    end
  end
end

Given(/^I click the value list link$/) do
  @contract = @current_user.reservations_bundles.signed_or_closed.order('RAND()').first
  within(".row.line[data-id='#{@contract.id}']") do
    find('.dropdown-toggle').click
    document_window = window_opened_by do
      click_link _('Value List')
    end
    page.driver.browser.switch_to.window(document_window.handle)
  end
end

Then(/^the value list opens$/) do
  expect(current_path).to eq borrow_user_value_list_path(@contract.id)
end

Given(/^I click the contract link$/) do
  @contract = @current_user.reservations_bundles.signed_or_closed.order('RAND()').first
  document_window = window_opened_by do
    find("a[href='#{borrow_user_contract_path(@contract.id)}']", text: _('Contract')).click
  end
  page.driver.browser.switch_to.window(document_window.handle)
end

Then(/^the contract opens$/) do
  expect(current_path).to eq borrow_user_contract_path(@contract.id)
end

When(/^I open a value list from my documents$/) do
  @contract = @current_user.reservations_bundles.signed_or_closed.order('RAND()').first
  visit borrow_user_value_list_path(@contract.id)
  #step "öffnet sich die Werteliste"
  step 'the value list opens'
  @list_element = find('.value_list')
end

When(/^I open a contract from my documents$/) do
  @contract = @current_user.reservations_bundles.signed_or_closed.order('RAND()').first
  visit borrow_user_contract_path(@contract.id)
  step 'the contract opens'
  @contract_element = find('.contract', match: :first)
end

When(/^I open a contract with returned items from my documents$/) do
  @contract = @current_user.reservations_bundles.signed_or_closed.find {|c| c.reservations.any? &:returned_to_user}
  visit borrow_user_contract_path(@contract.id)
  step 'the contract opens'
end

Then(/^I see the contract and it looks like in the manage section$/) do
  expect(has_selector?('.contract')).to be true
  # The rest is deleted: Dito, see above.
end

Then(/^the relevant reservations show the person taking back the item in the format "F. Lastname"$/) do
  if @reservations_to_take_back
    @reservations_to_take_back.map(&:contract).uniq.each do |contract|
      new_window = window_opened_by do
        find(".button[target='_blank'][href='#{manage_contract_path(@current_inventory_pool, contract)}']").click
      end
      within_window new_window do
        contract.reservations.each do |cl|
          find('.contract .list.returned_items tr', text: /#{cl.quantity}.*#{cl.item.inventory_code}.*#{I18n.l cl.end_date}/).find('.returning_date', text: cl.returned_to_user.short_name)
        end
      end
    end
  elsif @contract
    reservations = @contract.reservations.where.not(returned_date: nil)
    expect(reservations.size).to be > 0
    reservations.each do |cl|
      find('.contract .list.returned_items tr', text: cl.item.inventory_code).find('.returning_date', text: cl.returned_to_user.short_name)
    end
  end
end
