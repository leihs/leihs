# encoding: utf-8

#Wenn /^man den Kalender sieht$/ do
When /^I see the calendar$/ do
  step 'I open a contract for acknowledgement'
  @line_element = find(".line", match: :first)
  step 'I open the booking calendar for this line'
end

#Dann /^sehe ich die Verfügbarkeit von Modellen auch an Feier\- und Ferientagen sowie Wochenenden$/ do
Then /^I see the availability of models on weekdays as well as holidays and weekends$/ do
  while all(".fc-widget-content.holiday").empty? do
    find(".fc-button-next", match: :first).click
  end
  expect(find(".fc-widget-content.holiday .fc-day-content div", match: :first).text).not_to eq ""
  find(".fc-widget-content.holiday .fc-day-content div", match: :first).text.to_i >= 0
  expect(find(".fc-widget-content.holiday .fc-day-content .total_quantity", match: :first).text).not_to eq ""
end

When /^I open the booking calendar$/ do
  @line_el = if @contract.status == :submitted
               find(".order-line", match: :first)
             elsif @contract.status == :approved
               find(".line[data-line-type='item_line']", match: :first)
             end
  id = @line_el["data-id"] || JSON.parse(@line_el["data-ids"]).first
  @line = ContractLine.find_by_id id
  @line_el.find(".multibutton .button[data-edit-lines]", :text => _("Change entry")).click
  find(".fc-day-content", match: :first)
end

#Dann /^kann ich die Anzahl unbegrenzt erhöhen \/ überbuchen$/ do
Then /^there is no limit on augmenting the quantity, thus I can overbook$/ do
  @size = @line.model.items.where(:inventory_pool_id => @current_inventory_pool).size*2
  find(".modal").fill_in "booking-calendar-quantity", with: @size
  #expect(find(".modal #booking-calendar-quantity").value.to_i).to eq @size
end

#Dann /^die (Bestellung|Aushändigung) kann gespeichert werden$/ do |arg1|
Then /^the (order|hand over) can be saved$/ do |arg1|
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
  case arg1
    when "order"
      expect(@line.contract.lines.where(:start_date => @line.start_date, :end_date => @line.end_date, :model_id => @line.model).size).to eq @size
    when "hand over"
      expect(@line.contract.lines.where(:model_id => @line.model).size).to be >= @size
    else
      raise
  end
end

#Angenommen /^ich editiere alle Linien$/ do
Given /^I edit all lines$/ do
  find(".multibutton .green.dropdown-toggle").click
  find(".multibutton .dropdown-item[data-edit-lines='selected-lines']", :text => _("Edit Selection")).click
end

#Dann /^wird in der Liste unter dem Kalender die entsprechende Linie als nicht verfügbar \(rot\) ausgezeichnet$/ do
Then /^the list underneath the calendar shows the respective line as not available \(red\)$/ do
  find(".modal .line-info.red ~ .col5of10", match: :prefer_exact, :text => @model.name)
end
