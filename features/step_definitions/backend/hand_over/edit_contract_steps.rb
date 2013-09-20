When /^I select all lines$/ do
  all(".line").each do |line|
    cb = line.first(".select input")
    cb.click unless cb.checked?
  end
end

When /^I change the time range for all contract lines, envolving option and item lines$/ do
  step 'I add an option to the hand over by providing an inventory code and a date range'
  step 'I select all lines'
  step 'I edit the timerange of the selection'
  @line = @hand_over.lines.first
  @old_start_date = @line.start_date
  @new_start_date = if @line.start_date + 1.day < Date.today
      Date.today
    else
      @line.start_date + 1.day
  end
  get_fullcalendar_day_element(@new_start_date).click
  first("a", :text => /(Start Date|Startdatum)/).click
  step 'I save the booking calendar'
end

Then /^the time range for all contract lines is changed$/ do
  @customer.visits.hand_over.detect{|x| x.lines.size > 1}.lines.each do |line|
    line.start_date.should == @new_start_date
  end
end

When /^I change the time range for that option$/ do
  @option_line = @customer.visits.hand_over.collect(&:lines).flatten.detect{|x| x.is_a?(OptionLine)}
  first(".option_line", :text => @option_line.option.name).first(".button", :text => "Edit").click
  @new_start_date = change_line_start_date(@option_line, 2)
end

Then /^the time range for that option line is changed$/ do
  @option_line.reload.start_date.should == @new_start_date
end

When(/^I add an option$/) do
  @option = Option.find_by_inventory_pool_id @current_inventory_pool.id
  field_value = @option.name
  input_field = find("input.autocomplete", match: :first)
  input_field.click
  input_field.set field_value
  step "ensure there are no active requests"
  find("a[title='#{field_value}']", match: :first, text: field_value).click
end

When(/^I change the quantity right on the line$/) do
  quantity_input_field = find(".option_line", text: @option.name)
  @quantity = 5
  quantity_input_field.fill_in "quantity", :with => @quantity
  step "ensure there are no active requests"
  quantity_input_field.first("input[name='quantity']").value.should == @quantity.to_s
end

When(/^I decrease the quantity again$/) do
  @quantity = 1
  step 'I change the quantity right on the line'
end

Then(/^the quantity for that option line is changed$/) do
  OptionLine.last.quantity.should == @quantity
end
