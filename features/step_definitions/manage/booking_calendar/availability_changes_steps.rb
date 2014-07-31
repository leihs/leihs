When /^I open a booking calendar to edit a singe line$/ do
  @ip = @current_user.managed_inventory_pools.first
  # high frequently booked model
  @model = @ip.models.max {|a,b| a.availability_in(@ip).changes.length <=> b.availability_in(@ip).changes.length}
  @contract = Contract.joins(:contract_lines).where(:status => :submitted, :contract_lines => {:model_id => @model.id}).first
  visit manage_edit_contract_path(@ip, @contract)
  @edited_line = find(".line", :text => @model.name)
  @edited_line.find("[data-edit-lines]").click
  find(".modal")
end

Then /^I see all availabilities in that calendar, where the small number is the total quantity of that specific date$/ do
  within(".modal") do
    find("#booking-calendar .fc-widget-content", match: :first)
    # go to today
    while(all(".fc-button-prev:not(.fc-state-disabled)").length != 0)
      find(".fc-button-prev").click
    end
    av = @model.availability_in(@ip)
    changes = av.available_total_quantities
    changes.each_with_index do |c, i|
      current_calendar_date = Date.parse find(".fc-widget-content:not(.fc-other-month)", match: :first)["data-date"]
      current_change_date = c[0]
      while current_calendar_date.month != current_change_date.month do
        find(".fc-button-next").click
        current_calendar_date = Date.parse find(".fc-widget-content:not(.fc-other-month)", match: :first)["data-date"]
      end

      # iterate days between this change and the next one
      next_change = changes[i+1]
      if next_change
        days_between_changes = (next_change[0]-c[0]).to_i
        next_date = c[0]
        last_month = next_date.month
        days_between_changes.times do
          if next_date.month != last_month
            find(".fc-button-next").click
          end
          change_date_el = find(".fc-widget-content:not(.fc-other-month)[data-date='#{next_date.to_s(:db)}']")
          # check total, where the small number is the total quantity of that specific date
          total_quantity = c[1]
          # add quantity of edited line when date element is selected
          if change_date_el[:class].match("selected") != nil
            total_quantity += find("#booking-calendar-quantity").value.to_i
          end
          expect(change_date_el.find(".total_quantity").text[/-*\d+/].to_i).to eq total_quantity
          # check selected partition/borrower quantity
          quantity_for_borrower = av.maximum_available_in_period_summed_for_groups next_date, next_date, @contract.user.group_ids
          quantity_for_borrower += find("#booking-calendar-quantity").value.to_i if change_date_el[:class].match("selected") != nil

          expect(change_date_el.find(".fc-day-content div").text.to_i).to eq quantity_for_borrower
          last_month = next_date.month
          next_date += 1.day
        end
      end
    end
  end
end
