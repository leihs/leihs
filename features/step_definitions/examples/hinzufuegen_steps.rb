# -*- encoding : utf-8 -*-

Angenommen /^ich suche ein Modell um es hinzuzufügen$/ do
  @truncated_model_name = @current_user.managed_inventory_pools.first.items.first.model.name[0]
  first("#code").set @truncated_model_name
  page.execute_script('$("#code").focus()')
  first(".ui-autocomplete .ui-menu-item")
end

Dann /^sehe ich die Verfügbarkeit innerhalb der gefundenen Modelle im Format: "(.*?)"$/ do |arg1|
  start_date = Date.parse first("#add_start_date").value
  end_date = Date.parse first("#add_end_date").value
  all(".ui-autocomplete .ui-menu-item", :text => "Model").each do |item|
    model = Model.find_by_name item.first(".label").text
    av = model.availability_in(@ip)
    max_available = av.maximum_available_in_period_for_groups(start_date, end_date, @customer.group_ids)
    max_available_in_total = av.maximum_available_in_period_summed_for_groups(start_date, end_date)
    total_rentable = model.total_borrowable_items_for_user(@customer, @ip)
    availability_text = item.first(".availability").text
    availability_text.match(/#{max_available}\(/).should_not be_nil
    availability_text.match(/\(#{max_available_in_total}\)/).should_not be_nil
    availability_text.match(/\/#{total_rentable}/).should_not be_nil
  end
end