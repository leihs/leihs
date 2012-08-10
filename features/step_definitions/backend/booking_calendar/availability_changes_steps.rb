When /^I open a booking calendar to edit a singe line$/ do
  @ip = @user.managed_inventory_pools.first
  # high frequently booked model
  @model = @ip.models.max {|a,b| a.availability_in(@ip).changes.length <=> b.availability_in(@ip).changes.length}
  @order = OrderLine.where(:model_id => @model.id).first.order
  visit backend_inventory_pool_acknowledge_path(@ip, @order)
  find(".line", :text => @model.name).find(".actions .button").click
  wait_until { find(".dialog") }
end

Then /^I see all availability changes and availability in between the changes in that calendar$/ do
  # reset calendar to today first and then walk through
  find(".fc-button-today").click
  @model.availability_in(@ip).available_total_quantities.each do |change|
    current_calendar_date = Date.parse page.evaluate_script %Q{ $("#fullcalendar").fullCalendar("getDate").toDateString() }
    current_change_date = change[0]
    while current_calendar_date.month != current_change_date.month do
      find(".fc-button-next").click
    end
    #TODO: go on here
    change_date_el = find(".fc-widget-content:not(.fc-other-month) .fc-day-number", :text => /#{current_change_date.day}/).find(:xpath, "../..")
    change_date_el.find(".total_quantity").text.gsub(/\D/,"").to_i.should == change[1] 
  end
end