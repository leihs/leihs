# -*- encoding : utf-8 -*-

Given(/^I search for a model to add$/) do
  ('a'..'z').to_a.each do |letter|
    find('#add-input input, #assign-or-add-input input').set letter
    break if has_selector? '.ui-autocomplete .row'
  end
end

Then(/^the availability of the model is displayed as: "(?:.*?)"$/) do
  start_date = Date.parse find('#add-start-date').value
  end_date = Date.parse find('#add-end-date').value
  within '.ui-autocomplete' do
    all('a.row', text: 'Model').each do |item|
      name = item.find('.col3of4 strong').text
      model = Model.find_by_name(name)
      av = model.availability_in(@current_inventory_pool)
      max_available = av.maximum_available_in_period_for_groups(start_date, end_date, @customer.group_ids)
      max_available_in_total = av.maximum_available_in_period_summed_for_groups(start_date, end_date)
      total_rentable = model.total_borrowable_items_for_user(@customer, @current_inventory_pool)
      availability_text = item.find('.col1of4 .row:nth-child(1)').text
      expect(availability_text).to eq "#{max_available}(#{max_available_in_total})/#{total_rentable}"
    end
    find('.row', match: :first)
  end
end
