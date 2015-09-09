# -*- encoding : utf-8 -*-

When(/^I am viewing my current order$/) do
  visit borrow_current_order_path
end

Then(/^I am redirected to my current order$/) do
  expect(current_path).to eq borrow_current_order_path
end


Then(/^I do not see the order window$/) do
  expect(has_no_selector?('.col1of5 .navigation-tab-item', text: _('Order'))).to be true
end


Then(/^I see the order window$/) do
  expect(has_selector?('.col1of5 .navigation-tab-item', text: _('Order'))).to be true
end

Then(/^it appears in the order window$/) do
  visit borrow_root_path
  find('#current-order-basket', match: :first)
end

Then(/^the models in the order window are sorted alphabetically$/) do
  within '#current-order-basket #current-order-lines' do
    @names = all('.line').map{|l| l[:title] }
    expect(@names.sort == @names).to be true
  end
end

Then(/^identical models are collapsed$/) do
  expect(@names.uniq == @names).to be true
end

When(/^I add the same model one more time$/) do
  FactoryGirl.create(:reservation,
                     user: @current_user,
                     status: :unsubmitted,
                     inventory_pool: @inventory_pool,
                     model: @new_reservation.model)
  #step "erscheint es im Bestellfensterchen"
  step 'it appears in the order window'
end

Then(/^its quantity is increased$/) do
  within '#current-order-basket #current-order-lines' do
    line = find(".line[title='#{@new_reservation.model.name}']", match: :first)
    line.find('span', match: :first, text: "2x #{@new_reservation.model.name}")
  end
end

Then(/^I can go to the detailed order overview$/) do
  find('#current-order-basket .button.green', text: _('Complete order'))
end

When(/^I add a model to the order using the calendar$/) do
  #step 'man sich auf der Modellliste befindet'
  step 'I am listing models'
  #step 'man ein Startdatum auswählt'
  # choosing a start date is already implied in the step below
  #step 'I choose a start date'
  #step 'man auf einem verfügbaren Model "Zur Bestellung hinzufügen" wählt'
  step 'I add an existing model to the order'
  #step 'öffnet sich der Kalender'
  step 'the calendar opens'
  step 'everything I input into the calendar is valid'
end

Then(/^the order window is updated$/) do
  #step 'ist das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt worden'
  step 'the model has been added to the order with the respective start and end date, quantity and inventory pool'
  #step "erscheint es im Bestellfensterchen"
  step 'it appears in the order window'
  find("#current-order-basket #current-order-lines .line[title='#{@model.name}']", match: :first, text: "#{@quantity}x #{@model.name}")
end

Given(/^my order is empty$/) do
  # NOTE removing contracts already generated on the dataset
  @current_user.reservations.unsubmitted.map(&:destroy)

  expect(@current_user.reservations.unsubmitted.empty?).to be true
end

Then(/^I don't see a timer$/) do
  expect(has_no_selector?('#current-order-basket #timeout-countdown')).to be true
end

Then(/^I see a timer$/) do
  step 'I visit the homepage'
  expect(has_selector?('#current-order-basket #timeout-countdown', visible: true)).to be true
  @timeoutStart = if @current_user.reservations.unsubmitted.empty?
                    Time.now
                  else
                    @current_user.reservations.unsubmitted.order('RAND()').first.updated_at
                  end
  @countdown = find('#timeout-countdown-time', match: :first).text
end

Then(/^the timer is near the basket$/) do
  find('#current-order-basket .navigation-tab-item #timeout-countdown #timeout-countdown-time', match: :first)
end

Then(/^the timer counts down from (\d+) minutes$/) do |timeout_minutes|
  @countdown = find('#timeout-countdown-time', match: :first).text
  minutes = @countdown.split(':')[0].to_i
  seconds = @countdown.split(':')[1].to_i
  sleep(1) # NOTE this sleep is required in order to test the countdown
  expect(Setting.timeout_minutes - 1).to be <= minutes
  expect(find('#timeout-countdown-time', match: :first).reload.text.split(':')[1].to_i).to be < seconds
end

Given(/^my order is not empty$/) do
  #step 'ich ein Modell der Bestellung hinzufüge'
  step 'I add a model to an order'
end

When(/^I reset the timer$/) do
  @countdown = find('#timeout-countdown-time', match: :first).text
  find('#timeout-countdown-refresh', match: :first).click
end

Then(/^the timer is reset$/) do
  seconds = @countdown.split(':')[1].to_i
  secondsNow = find('#timeout-countdown-time', match: :first).reload.text.split(':')[1].to_i
  expect(secondsNow).to be >= seconds
end

Given(/^the timeout is set to (\d+) minutes?$/) do |arg1|
  Setting.first.update_attributes(timeout_minutes: arg1.to_i)
  expect(Setting.timeout_minutes).to eq arg1.to_i
end

When(/^the timer has run down$/) do
  sleep(Setting.timeout_minutes * 60 + 1) # NOTE this sleep is required to test the timeout
end
