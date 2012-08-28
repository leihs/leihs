# encoding: utf-8

Wenn /^man den Kalender sieht$/ do
  step 'I open an order for acknowledgement'
  @line_element = find(".line")
  step 'I open the booking calendar for this line'
end

Dann /^sehe ich die Verfügbarkeit von Modellen auch an Feier\- und Ferientagen sowie Wochenenden$/ do
  while all(".fc-widget-content.holiday").empty? do
    find(".fc-button-next").click
  end
  find(".fc-widget-content.holiday .fc-day-content div").text.should_not == ""
  find(".fc-widget-content.holiday .fc-day-content div").text.to_i >= 0
  find(".fc-widget-content.holiday .fc-day-content .total_quantity").text.should_not == ""
end

Angenommen /^ich öffne den Kalender$/ do
  @line_el = find(".line")
  @line = if @event == "order"
    OrderLine.find_by_id @line_el["data-id"]
  elsif @event == "hand_over"
    ContractLine.find_by_id @line_el["data-id"]
  end
  @line_el.find(".actions .button", :text => "Edit").click
  wait_until { find(".fc-day-content") }
end

Dann /^kann ich die Anzahl unbegrenzt erhöhen \/ überbuchen$/ do
  @size = @line.model.items.where(:inventory_pool_id => @ip).size*2
  find(".dialog #quantity").set @size
  find(".dialog #quantity").value.to_i.should == @size
end

Dann /^die Bestellung kann gespeichert werden$/ do
  step 'I save the booking calendar'
  @line.reload.quantity.should == @size
end

Dann /^die Aushändigung kann gespeichert werden$/ do
  step 'I save the booking calendar'
  @line.contract.lines.where(:model_id => @line.model).size.should >= @size
end

Angenommen /^ich editiere alle Linien$/ do
  find("#selection_actions .actions .trigger").click
  find("#selection_actions .actions .button", :text => "Edit Selection").click
end

Dann /^wird in der Liste unter dem Kalender die entsprechende Linie als nicht verfügbar \(rot\) ausgezeichnet$/ do
  wait_until{ find(".dialog .list .line.unavailable", :text => @model.name) }
end