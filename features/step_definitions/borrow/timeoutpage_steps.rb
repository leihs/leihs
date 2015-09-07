# -*- encoding : utf-8 -*-

Given(/^I hit the timeout page with a model that has conflicts$/) do
  step 'I have an unsubmitted order with models'
  step 'a model is not available'
  step 'I have performed no activity for more than 30 minutes'
  step 'I perform some activity'
  step 'I am redirected to the timeout page'
  step 'I am informed that my items are no longer reserved for me'
end

Given(/^I hit the timeout page with (\d+) models that have conflicts$/) do |n|
  step 'I have an unsubmitted order with models'
  step "#{n} models are not available"
  step 'I have performed no activity for more than 30 minutes'
  step 'I perform some activity'
  step 'I am redirected to the timeout page'
  step 'I am informed that my items are no longer reserved for me'
end

Then(/^I am informed that my items are no longer reserved for me$/) do
  expect(has_content?(_('%d minutes passed. The items are not reserved for you any more!') % Contract::TIMEOUT_MINUTES)).to be true
end

Then(/^I am informed that the remaining models are all available$/) do
  expect(has_content?(_('Your order has been modified. All reservations are now available.'))).to be true
end

#########################################################################

Then(/^I see my order$/) do
  find('#current-order-lines')
end

Then(/^the no longer available items are highlighted$/) do
  @current_user.reservations.unsubmitted.each do |line|
    unless line.available?
      find("[data-ids*='#{line.id}']", match: :first).find(:xpath, './../../..').find(".line-info.red[title='#{_("Not available")}']")
    end
  end
end

Then(/^I can delete entries$/) do
  all('.row.line').each do |x|
    x.find('a', match: :first, text: _('Delete'))
  end
end

Then(/^I can edit entries$/) do
  all('.row.line').each do |x|
    x.find('button', text: _('Change entry'))
  end
end

Then(/^I can return to the main order overview$/) do
  find('a', text: _('Continue this order'))
end

#########################################################################

Then(/^the user's order has been deleted$/) do
  @contracts.each do |contract|
    expect { contract.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

#########################################################################

Given(/^I delete one entry$/) do
  line = all('.row.line').to_a.sample
  @line_ids = line.find('button[data-ids]')['data-ids'].gsub(/\[|\]/, '').split(',').map(&:to_i)
  expect(@line_ids.all? { |id| @current_user.reservations.unsubmitted.map(&:id).include?(id) }).to be true
  line.find('.dropdown-toggle').click
  line.find('a', text: _('Delete')).click
  step 'I am asked whether I really want to delete'
end

Then(/^the entry is deleted from the order$/) do
  expect(@line_ids.all? { |id| page.has_no_selector? "button[data-ids='[#{id}]']" }).to be true
  expect(@line_ids.all? { |id| not @current_user.reservations.unsubmitted.map(&:id).include?(id) }).to be true
end

#########################################################################

# Given(/^I modify one entry$/) do
#   #step "ich den Eintrag ändere"
#   step 'I change the entry'
#   #step "öffnet der Kalender"
#   step 'the calendar opens'
#   #step "ich ändere die aktuellen Einstellung"
#   step 'I change the date'
#   step "I save the booking calendar"
# end

When(/^I (increase|decrease) the quantity of one entry$/) do |arg1|
  #step "ich den Eintrag ändere"
  step 'I change the entry'
  #step "öffnet der Kalender"
  step 'the calendar opens'
  @new_quantity = case arg1
                    when 'increase'
                      find('#booking-calendar-quantity')[:max].to_i
                    when 'decrease'
                      1
                    else
                      raise
                  end
  find('#booking-calendar-quantity').set(@new_quantity)
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
end

# Then(/^the changes I made are saved$/) do
#   #step "wird der Eintrag gemäss aktuellen Einstellungen geändert"
#   step "the entry's date is changed accordingly"
#   #step "der Eintrag wird in der Liste anhand der des aktuellen Startdatums und des Geräteparks gruppiert"
#   step 'the entry is grouped based on its current start date and inventory pool'
# end

When(/^I have performed no activity for more than (\d+) minutes$/) do |minutes|
  Timecop.travel(Time.now + (minutes.to_i + 1).minutes)
end

When(/^the unavailable models are deleted from the order$/) do
  expect(@current_user.reservations.unsubmitted.all? { |l| l.available? }).to be true
end

When(/^I correct one of the errors$/) do
  @line_ids = @current_user.reservations.unsubmitted.select { |l| not l.available? }.map(&:id)
  resolve_conflict_for_reservation @line_ids.delete_at(0)
end

When(/^I correct all errors$/) do
  @line_ids.each do |line_id|
    resolve_conflict_for_reservation line_id
  end
end

Then(/^the error message appears$/) do
  expect(has_no_content? _('Please solve the conflicts for all highlighted reservations in order to continue.')).to be true
end

def resolve_conflict_for_reservation(line_id)
  within ".line[data-ids='[#{line_id}]']" do
    find('.button', text: _('Change entry')).click
  end
  expect(has_selector?('#booking-calendar .fc-day-content')).to be true
  find('#booking-calendar-quantity').set 1

  start_date = select_available_not_closed_date
  select_available_not_closed_date(:end, start_date)
  find('.modal .button.green').click

  step 'the booking calendar is closed'
  within ".line[data-ids='[#{line_id}]']" do
    expect(has_no_selector?('.line-info.red')).to be true
  end
end
