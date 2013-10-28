When /^I open a booking calendar to edit a singe line$/ do
  @ip = @current_user.managed_inventory_pools.first
  # high frequently booked model
  @model = @ip.models.max {|a,b| a.availability_in(@ip).changes.length <=> b.availability_in(@ip).changes.length}
  @contract = Contract.joins(:contract_lines).where(:status => :submitted, :contract_lines => {:model_id => @model.id}).first
  visit backend_inventory_pool_acknowledge_path(@ip, @contract)
  @edited_line = find(".line", :text => @model.name)
  @edited_line.find(".actions .button").click
  find(".dialog")
end

Then /^I see all availabilities in that calendar, where the small number is the total quantity of that specific date$/ do
  # reset calendar to today first and then walk through
  find(".fc-button-today").click
  av = @model.availability_in(@ip)
  changes = av.available_total_quantities
  changes.each_with_index do |change, i|
    current_calendar_date = Date.parse page.evaluate_script %Q{ $("#fullcalendar").fullCalendar("getDate").toDateString() }
    current_change_date = change[0]
    while current_calendar_date.month != current_change_date.month do
      find(".fc-button-next").click
      current_calendar_date = Date.parse page.evaluate_script %Q{ $("#fullcalendar").fullCalendar("getDate").toDateString() }
    end
    
    # iterate days between this change and the next one
    next_change = changes[i+1]
    if next_change
      days_between_changes = (next_change[0]-change[0]).to_i
      next_date = change[0]
      last_month = next_date.month
      days_between_changes.times do
        if next_date.month != last_month
          find(".fc-button-next").click
        end
        change_date_el = find(".fc-widget-content:not(.fc-other-month) .fc-day-number", :text => /#{next_date.day}/, :match => :first).first(:xpath, "../..")
        # check total, where the small number is the total quantity of that specific date
        total_quantity = change[1]
        # add quantity of edited line when date element is selected
        if change_date_el[:class].match("selected") != nil
          total_quantity += evaluate_script %Q{ $(".dialog").tmplItem().data.quantity }
        end
        change_date_el.find(".total_quantity").text[/-*\d+/].to_i.should == total_quantity
        # check selected partition/borrower quantity
        quantity_for_borrower = av.maximum_available_in_period_summed_for_groups next_date, next_date, @contract.user.group_ids
        quantity_for_borrower += evaluate_script %Q{ $(".dialog").tmplItem().data.quantity }  if change_date_el[:class].match("selected") != nil

        change_date_el.find(".fc-day-content div").text.to_i.should == quantity_for_borrower
        last_month = next_date.month
        next_date += 1.day
      end
    end
  end
end
