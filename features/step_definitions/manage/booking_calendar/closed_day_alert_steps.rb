When /^I pick a closed day for beeing the (start|end) date$/ do |date_target|
  next_closed_day = nil
  date = Date.today
  expect(has_selector?("td[data-date]")).to be true
  if all("td[data-date='#{date}']").empty? then
    date = Date.new(date.year, date.month + 1)
  end

  while next_closed_day.nil?
    next_date = @current_inventory_pool.next_open_date date+1.day
    next_closed_day = (next_date - 1.day) if (next_date-date).to_i > 1
    date = date+1.day
  end
  get_fullcalendar_day_element(next_closed_day).click

  case date_target
    when "start"
      find("#set-start-date", text: _("Start Date")).click
    when "end"
      find("#set-end-date", text: _("End Date")).click
  end
end

Then /^the (start|end) date becomes red and I see a (closed|not possible|too early) day warning?$/ do |arg1, arg2|
  within ".modal" do
    el = find(".fc-widget-content.closed.#{arg1}-date").native.style('background-color')
    # NOTE our red definition is #FF4C4D == rgba(255, 76, 77, 1)
    expect(el).to eq "rgba(255, 76, 77, 1)"

    s = case arg2
          when "closed"
            _("Inventory pool is closed on #{arg1} date")
          when "not possible"
            _("Booking is no longer possible on this #{arg1} date")
          when "too early"
            _("No orders are possible on this start date")
        end
    find(".red", text: s)
  end
end
