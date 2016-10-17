When(/^I open the inventory$/) do
  find('#topbar .topbar-navigation .topbar-item a', text: _('Inventory')).click
  expect(current_path).to eq manage_inventory_path(@current_inventory_pool)
end

#Then(/^I can export to a csv-file$/) do
Then(/^I can export to a CSV file$/) do
  find('#csv-export')
end

Then(/^I can search and filter$/) do
  expect(has_selector?('#inventory-index-view form[data-filter]')).to be true
end

Then(/^I can not edit models, items, options, software or licenses$/) do
  within '#inventory' do
    find('.line', match: :first)

    # clicking on all togglers via javascript is significantly faster than doing it with capybara in this case
    page.execute_script %Q( $(".button[data-type='inventory-expander']").click() )
    sleep 2

    all('.line', visible: true)[0..5].each do |line|
      within line.find('.line-actions') do
        expect(has_no_selector?('a', text: _('Edit Model'))).to be true
        expect(has_no_selector?('a', text: _('Edit Item'))).to be true
        expect(has_no_selector?('a', text: _('Edit Option'))).to be true
        expect(has_no_selector?('a', text: _('Edit Software'))).to be true
        expect(has_no_selector?('a', text: _('Edit License'))).to be true
      end
    end
  end
end

Then(/^I can not add models, items, options, software or licenses$/) do
  within '#inventory-index-view' do
    expect(has_no_selector?('.button', text: _('Add inventory'))).to be true
  end
end

When(/^I enter the timeline of a model with hand overs, take backs or pending orders$/) do
  within '#inventory' do
    all(".line[data-type='model']", minimum: 1).each do |line|
      if @current_inventory_pool.running_reservations.detect { |rl| rl.model_id == line['data-id'].to_i }
        line.find('.line-actions > a', text: _('Timeline')).click
        break
      end
    end
  end
  find('.modal iframe')
end

When(/^I click on a user's name$/) do
  within_frame 'timeline' do
    find('.timeline-band-events .timeline-event-label').click
  end
end

Then(/^there is no link to:$/) do |table|
  within_frame 'timeline' do
    within '.simileAjax-bubble-container .simileAjax-bubble-contentContainer' do
      table.raw.flatten.each do |s1|
        s2 = case s1
               when 'acknowledge'
                 _('Acknowledge')
               when 'hand over'
                 _('Hand Over')
               when 'take back'
                 _('Take Back')
               else
                 raise
             end
        expect(has_no_selector?('a', text: s2)).to be true
      end
    end
  end
end

When(/^I open a submitted order to be verified by a Group Manager$/) do
  @contract = @current_inventory_pool.reservations_bundles.submitted.with_verifiable_user_and_model.order('RAND()').first
  step 'I edit this submitted contract'
end

When(/^I add a model which leads to an overbooking$/) do
  ('a'..'z').each do |char|
    type_into_autocomplete '#assign-or-add-input input, #add-input input', char
    if has_selector?('.ui-autocomplete a.light-red')
      find('.ui-autocomplete a.light-red', match: :first).click
      break
    end
  end
end

When(/^I open a hand over editable by the Group Manager$/) do
  @contract = @current_inventory_pool.reservations_bundles.approved.with_verifiable_user_and_model.order('RAND()').first
  visit manage_hand_over_path(@current_inventory_pool, @contract.user)
  expect(has_selector?('#hand-over-view')).to be true
  step 'the availability is loaded'
end
