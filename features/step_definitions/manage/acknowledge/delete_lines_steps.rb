# -*- encoding : utf-8 -*-

When /^I delete a line of this contract$/ do
  @line = @contract.reservations.first
  @line_element = find('.line', match: :prefer_exact, text: @line.model.name)
  within @line_element do
    within('.multibutton') do
      find('.dropdown-toggle').click
      find('.red[data-destroy-lines]', text: _('Delete')).click
    end
  end
end

Then /^this reservation is deleted$/ do
  expect(has_no_selector?('.line', match: :prefer_exact, text: @line.model.name)).to be true
  expect(@contract.reservations.reload.include?(@line)).to be false
end

When /^I delete multiple reservations of this contract$/ do
  step 'I add a model that is not already part of that contract'
  all('input[data-select-line]:checked').each do |checkbox|
    checkbox.click
  end
  step 'I select two reservations'
  find('.multibutton [data-selection-enabled] + .dropdown-holder').click
  find('a', text: _('Delete Selection')).click
  find('.line', match: :first)
end

When(/^I add a model that is not already part of that contract$/) do
  @item = (@current_inventory_pool.models.order('RAND()') - @contract.models).first.items.order('RAND()').first
  step 'I add a model by typing in the inventory code of an item of that model to the quick add'
end

Then /^these reservations are deleted$/ do
  step 'the availability is loaded'
  expect { @line1.reload }.to raise_error(ActiveRecord::RecordNotFound)
  expect { @line2.reload }.to raise_error(ActiveRecord::RecordNotFound)
end

When /^I delete all reservations of this contract$/ do
  find('.line input[type=checkbox]', match: :first)
  all('.line input[type=checkbox]').each &:click
  find('.multibutton [data-selection-enabled] + .dropdown-holder').click
  find('a', text: _('Delete Selection')).click
  find('.line', match: :first)
end

Then /^I got an error message that not all reservations can be deleted$/ do
  find('#flash .error', text: _('You cannot delete all reservations of an contract. Perhaps you want to reject it instead?'))
end

Then /^none of the reservations are deleted$/ do
  expect(@contract.reservations.count).to be > 0
end

When(/^I delete a hand over$/) do
  @visit = @current_inventory_pool.visits.hand_over.where(date: Date.today).order('RAND()').first
  expect(@visit).not_to be_nil
  expect(@visit.reservations.empty?).to be false
  @visit_line_ids = @visit.reservations.map(&:id)
  within(".line[data-id='#{@visit.id}']") do
    find('.line-actions .multibutton .dropdown-holder').click
    find('.dropdown-item[data-hand-over-delete]', text: _('Delete')).click
  end
end

Then(/^all reservations of that hand over are deleted$/) do
  within(".line[data-id='#{@visit.id}']") do
    find('.line-actions', text: _('Deleted'))
  end
  reloaded_visit = Visit.having('id = ?', @visit.id).first
  expect(reloaded_visit).to be_nil
  @visit_line_ids.each do |line_id|
    expect { Reservation.find(line_id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
