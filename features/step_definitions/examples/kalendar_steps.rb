# encoding: utf-8

Wenn /^man den Kalender sieht$/ do
  step 'I open an order for acknowledgement'
  @line_element = first(".line")
  step 'I open the booking calendar for this line'
end

Dann /^sehe ich die Verfügbarkeit von Modellen auch an Feier\- und Ferientagen sowie Wochenenden$/ do
  while all(".fc-widget-content.holiday").empty? do
    first(".fc-button-next").click
  end
  first(".fc-widget-content.holiday .fc-day-content div").text.should_not == ""
  first(".fc-widget-content.holiday .fc-day-content div").text.to_i >= 0
  first(".fc-widget-content.holiday .fc-day-content .total_quantity").text.should_not == ""
end

Angenommen /^ich öffne den Kalender$/ do
  @line_el = find(".line", match: :first)
  @line = if @event == "order"
    OrderLine.find_by_id @line_el["data-id"]
  elsif @event == "hand_over"
    ContractLine.find_by_id @line_el["data-id"]
  end
  @line_el.first(".actions .button", :text => /(Edit|Editieren)/).click
  first(".fc-day-content")
end

Dann /^kann ich die Anzahl unbegrenzt erhöhen \/ überbuchen$/ do
  @size = @line.model.items.where(:inventory_pool_id => @ip).size*2
  first(".dialog #quantity").set @size
  first(".dialog #quantity").value.to_i.should == @size
end

Dann /^die Bestellung kann gespeichert werden$/ do
  step 'I save the booking calendar'
  @line.order.lines.where(:start_date => @line.start_date, :end_date => @line.end_date, :model_id => @line.model).size == @size
end

Dann /^die Aushändigung kann gespeichert werden$/ do
  step 'I save the booking calendar'
  @line.contract.lines.where(:model_id => @line.model).size.should >= @size
end

Angenommen /^ich editiere alle Linien$/ do
  first("#selection_actions .actions .trigger").click
  first("#selection_actions .actions .button", :text => /(Edit Selection|Auswahl editieren)/).click
end

Dann /^wird in der Liste unter dem Kalender die entsprechende Linie als nicht verfügbar \(rot\) ausgezeichnet$/ do
  first(".dialog .list .line.unavailable", :text => @model.name)
end
