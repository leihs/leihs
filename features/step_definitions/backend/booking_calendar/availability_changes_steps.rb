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
  av = @model.availability_in(@ip) 
  changes = av.available_total_quantities
  changes.each_with_index do |change, i|
    current_calendar_date = Date.parse page.evaluate_script %Q{ $("#fullcalendar").fullCalendar("getDate").toDateString() }
    current_change_date = change[0]
    while current_calendar_date.month != current_change_date.month do
      find(".fc-button-next").click
    end
    
    # itterate days between this change and the next one
    next_change = changes[i+1]
    if next_change
      days_between_changes = (next_change[0]-change[0]).to_i
      next_date = change[0]
      last_month = next_date.month
      days_between_changes.times do
        if next_date.month != last_month
          find(".fc-button-next").click   
        end
        change_date_el = find(".fc-widget-content:not(.fc-other-month) .fc-day-number", :text => /#{next_date.day}/).find(:xpath, "../..")
        # check total
        total_quantity = change[1]
        # add quantity of edited line when date element is selected
        if change_date_el[:class].match("selected") != nil
          total_quantity += evaluate_script %Q{ $(".dialog").tmplItem().data.quantity }
        end
        change_date_el.find(".total_quantity").text.gsub(/\D/,"").to_i.should == total_quantity
        # check selected partition/borrower quantity
        quantity_for_borrower = @model.availability_in(@ip).maximum_available_in_period_summed_for_groups @order.user.group_ids, next_date, next_date
        quantity_for_borrower += evaluate_script %Q{ $(".dialog").tmplItem().data.quantity }  if change_date_el[:class].match("selected") != nil

        ##### debug informations for ci
        if change_date_el.find(".fc-day-content div").text.to_i != quantity_for_borrower
          puts "DEBUGING INFORMATIONS FOR CI"
          puts "availability", av
          puts "reloaded availability", @model.reload.availability_in(@ip.reload)
          puts "order", @order.user.to_json
          puts "CHANGES", changes
          puts "CHANGE", change
          puts "NEXT CHANGE:", next_change
          puts "NEXT DATE:", next_date 
          puts "CHANGE DATE EL:", change_date_el 
          puts "CHANGE DATE EL TEXT:", change_date_el.text
          puts "QUANTITY FOR BORROWER:", quantity_for_borrower
          puts "JSON DATA (removed blocking line)", page.evaluate_script(%Q{ $(".dialog").tmplItem().data })
          puts "JSON PLAIN (unmodified)", page.evaluate_script(%Q{ inspect_order_json })
        end
        ##### debug informations for ci

        change_date_el.find(".fc-day-content div").text.to_i.should == quantity_for_borrower
        last_month = next_date.month
        next_date += 1.day
      end
    end
  end
end