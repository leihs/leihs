# -*- encoding : utf-8 -*-

When /^I open an order for acknowledgement$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|x| x.orders.submitted.exists? }
  @order = @customer.orders.submitted.first
  visit backend_inventory_pool_acknowledge_path(@ip, @order)
  page.should have_selector("#acknowledge", :visible => true)
end

When /^I open an order for acknowledgement with more then one line$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|x| x.orders.submitted.exists? and x.orders.submitted.first.lines.size > 1}
  @order = @customer.orders.submitted.first
  visit backend_inventory_pool_acknowledge_path(@ip, @order)
  page.should have_selector("#acknowledge", :visible => true)
end

When /^I open the booking calendar for this line$/ do
  @line_element.first(".button", :text => /(Edit|Editieren)/).click
  step "I see the booking calendar"
end

When /^I edit the timerange of the selection$/ do
  page.execute_script('$("#selection_actions .button").show()')
  first(".button", :text => /(Edit Selection|Auswahl editieren)/).click
  step "I see the booking calendar"
end

When /^I save the booking calendar$/ do
  first(".dialog .button", :text => /(Save Changes|Änderungen speichern)/).click
  step "ensure there are no active requests"
  page.should_not have_selector(".dialog")
end

When /^I change (.*?) lines time range$/ do |type|
  @line = case type
  when "an order"
    @order.lines.first
  when "a contract"
    @customer.visits.hand_over.first.lines.first
  end
  @line_element = find(".line[data-id='#{@line.id}']")
  step 'I open the booking calendar for this line'
  @new_start_date = if @line.start_date + 1.day < Date.today
      Date.today
    else
      @line.start_date + 1.day
  end
  page.should have_selector(".fc-widget-content .fc-day-number")
  get_fullcalendar_day_element(@new_start_date).click
  first("a", :text => /(Start Date|Startdatum)/).click
  step 'I save the booking calendar'
end

Then /^the time range of that line is changed$/ do
  @line.reload.start_date.should == @new_start_date
end

When /^I change (.*?) lines quantity$/ do |type|
  @line = case type
  when "an order"
    @order.lines.first
  when "a contract"
    @customer.visits.hand_over.first.lines.first
  end
  @line_element = find(".line", match: :first, :text => @line.model.name)
  step 'I open the booking calendar for this line'
  @new_quantity = @line.model.total_borrowable_items_for_user @customer
  first(".dialog input#quantity").set @new_quantity
  step 'I save the booking calendar'
end

Then /^the quantity of that line is changed$/ do
  @line_element = find(".line", match: :first, :text => @line.model.name)
  @line_element.first(".amount .selected").text.should == @new_quantity.to_s
end

When /^I select two lines$/ do
  @line1 = @order.lines.first
  @line1_element = find(".line", match: :first, :text => @line1.model.name)
  @line1_element.first("input[type=checkbox]").click
  @line2 = @order.lines.second
  @line2_element = find(".line", match: :first, :text => @line2.model.name)
  @line2_element.first("input[type=checkbox]").click
end

When /^I change the time range for multiple lines$/ do
  step 'I select two lines'
  step 'I edit the timerange of the selection'
  @new_start_date = @line1.start_date + 2.days
  get_fullcalendar_day_element(@new_start_date).click
  first("a", :text => /(Start Date|Startdatum)/).click
  step 'I save the booking calendar'
end

Then /^the time range for that lines is changed$/ do
  @line1.reload.start_date.should == @line2.reload.start_date 
  @line1.reload.start_date.should == @new_start_date
end

When /^I close the booking calendar$/ do
  first(".dialog .button.close_dialog").click
end

When /^I edit one of the selected lines$/ do
  all(".line").each do |line|
    if line.first("input").checked?
      @line_element = line
    end
  end
  step 'I open the booking calendar for this line'
end

Then /^I see the booking calendar$/ do
  page.should have_selector("#fullcalendar .fc-day-content")
end

When /^I change the time range for multiple lines that have quantity bigger then (\d+)$/ do |arg1|
  step 'I change an order lines quantity'
  first(".line[data-id='#{@line.id}'] .selected").text.to_i.should == @new_quantity
  step 'I change the time range for multiple lines'
end

Then /^the quantity is not changed after just moving the lines start and end date$/ do
  first(".line[data-id='#{@line.id}'] .selected").text.to_i.should == @new_quantity
end
