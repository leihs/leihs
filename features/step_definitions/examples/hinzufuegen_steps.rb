# -*- encoding : utf-8 -*-

#Angenommen /^ich suche ein Modell um es hinzuzufügen$/ do
  Given(/^I search for a model to add$/) do
  @truncated_model_name = @current_user.inventory_pools.managed.first.items.first.model.name[0]
  find("[data-add-contract-line]").set @truncated_model_name
  find(".ui-autocomplete .ui-menu-item", match: :first)
end

#Dann /^sehe ich die Verfügbarkeit innerhalb der gefundenen Modelle im Format: "(.*?)"$/ do |arg1|
Then(/^the availability of the model is displayed as: "(?:.*?)"$/) do
  start_date = Date.parse find("#add-start-date").value
  end_date = Date.parse find("#add-end-date").value
  find(".ui-autocomplete .ui-menu-item", match: :first)
  all(".ui-autocomplete .ui-menu-item", :text => "Model").each do |item|
    name = item.find(".col3of4 strong").text
    model = Model.find_by_name(name)
    av = model.availability_in(@current_inventory_pool)
    max_available = av.maximum_available_in_period_for_groups(start_date, end_date, @customer.group_ids)
    max_available_in_total = av.maximum_available_in_period_summed_for_groups(start_date, end_date)
    total_rentable = model.total_borrowable_items_for_user(@customer, @current_inventory_pool)
    availability_text = item.find(".col1of4 .row:nth-child(1)").text
    expect(availability_text).to eq "#{max_available}(#{max_available_in_total})/#{total_rentable}"
  end
  find(".ui-autocomplete .ui-menu-item", match: :first)
end
