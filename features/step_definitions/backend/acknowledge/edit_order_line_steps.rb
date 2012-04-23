When /^I open an order for acknowledgement$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|x| x.orders.submitted.count > 0}
  @order = @customer.orders.submitted.first
  visit backend_inventory_pool_acknowledge_path(@ip, @order)
  page.has_css?("#acknowledge", :visible => true)
end

When /^I open an order for acknowledgement with more then one line$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|x| x.orders.submitted.count > 0 and x.orders.submitted.first.lines.size > 1}
  @order = @customer.orders.submitted.first
  visit backend_inventory_pool_acknowledge_path(@ip, @order)
  page.has_css?("#acknowledge", :visible => true)
end

When /^I open the booking calendar for this line$/ do
  @line_element.find(".button", :text => "Edit").click
  wait_until { find("#fullcalendar .fc-day-content") }
end

When /^I edit the timerange of the selection$/ do
  find(".button", :text => "Edit Selection").click
  wait_until { find("#fullcalendar .fc-day-content") }
end

When /^I save the booking calendar$/ do
  find(".dialog .button", :text => "Save Changes").click
  wait_until { all(".dialog").size == 0 }
end

When /^I change a lines time range$/ do
  @line = @order.lines.first
  @line_element = find(".line", :text => @line.model.name)
  step 'I open the booking calendar for this line'
  @new_start_date = @line.start_date+1
  wait_until { find(".fc-widget-content:not(.fc-other-month) .fc-day-number") }
  @new_start_date_element = all(".fc-widget-content .fc-day-number", :text => /^#{@new_start_date.day}$/).last
  @new_start_date_element.click
  find("a", :text => "Start Date").click
  step 'I save the booking calendar'
end

Then /^the time range of that order line is changed$/ do
  @line.reload.start_date.should == @new_start_date
end

When /^I change a lines quantity$/ do
  @line = @order.lines.first
  @line_element = find(".line", :text => @line.model.name)
  step 'I open the booking calendar for this line'
  @new_quantity = @line.model.items.size
  find(".dialog input#quantity").set @new_quantity
  step 'I save the booking calendar'
end

Then /^the quantity of that order line is changed$/ do
  @line_element = find(".line", :text => @line.model.name)
  @line_element.find(".amount .selected").text.should == @new_quantity.to_s
end

When /^I change the time range for multiple lines$/ do
  @line1 = @order.lines.first
  @line1_element = find(".line", :text => @line1.model.name)
  @line1_element.find("input[type=checkbox]").click
  @line2 = @order.lines.second
  @line2_element = find(".line", :text => @line2.model.name)
  @line2_element.find("input[type=checkbox]").click
  step 'I edit the timerange of the selection'
  @new_start_date = @line1.start_date+2
  @new_start_date_element = all(".fc-widget-content .fc-day-number", :text => /^#{@new_start_date.day}$/).last
  @new_start_date_element.click
  find("a", :text => "Start Date").click
  step 'I save the booking calendar'
end

Then /^the time range for that order lines is changed$/ do
  @line1.reload.start_date.should == @line2.reload.start_date 
  @line1.reload.start_date.should == @new_start_date
end