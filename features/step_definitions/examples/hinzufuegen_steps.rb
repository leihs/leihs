# -*- encoding : utf-8 -*-

Angenommen /^ich suche ein Modell um es hinzuzufügen$/ do
  @truncated_model_name = @current_user.managed_inventory_pools.first.items.first.model.name[0]
  find("[data-add-contract-line]").set @truncated_model_name
  find(".ui-autocomplete .ui-menu-item", match: :first)
end

Dann /^sehe ich die Verfügbarkeit innerhalb der gefundenen Modelle im Format: "(.*?)"$/ do |arg1|
  start_date = Date.parse find("#add-start-date").value
  end_date = Date.parse find("#add-end-date").value
  find(".ui-autocomplete .ui-menu-item", match: :first)
  all(".ui-autocomplete .ui-menu-item", :text => "Model").each do |item|
    model = Model.find_by_name item.find(".col3of4 strong").text
    av = model.availability_in(@ip)
    max_available = av.maximum_available_in_period_for_groups(start_date, end_date, @customer.group_ids)
    max_available_in_total = av.maximum_available_in_period_summed_for_groups(start_date, end_date)
    total_rentable = model.total_borrowable_items_for_user(@customer, @ip)
    availability_text = item.find(".col1of4 .row:nth-child(1)").text
    availability_text.match(/#{max_available}\(/).should_not be_nil
    availability_text.match(/\(#{max_available_in_total}\)/).should_not be_nil
    availability_text.match(/\/#{total_rentable}/).should_not be_nil
  end
  find(".ui-autocomplete .ui-menu-item", match: :first)
end