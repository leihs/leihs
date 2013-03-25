When /^I pick a closed day for beeing the "(.*?)"$/ do |date_target|
  next_closed_day = nil
  date = Date.today
  if all("td[data-date='#{date}']").empty? then date = Date.new(date.year, date.month + 1) end

  while next_closed_day.nil?
    next_date = @ip.next_open_date date+1.day
    next_closed_day = (next_date - 1.day) if (next_date-date).to_i > 1
    date = date+1.day
  end
  @date_el = get_fullcalendar_day_element(next_closed_day)
  @date_el.click
  find("a", :text => /(Start Date|Startdatum)/).click if date_target == "start date"
  find("a", :text => /(End Date|Enddatum)/).click if date_target == "end date"
end

Then /^this date becomes red and I see a closed day warning$/ do
  @date_el[:class][/closed/].should_not be_nil
  find(".ui-tooltip.closed-day-alert")
end
