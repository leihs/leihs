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
