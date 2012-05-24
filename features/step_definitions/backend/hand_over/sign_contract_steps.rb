When /^I open a hand over$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|x| x.contracts.unsigned.count > 0}
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#hand_over", :visible => true)
end

When /^I select an item line and assign an inventory code$/ do
  @item_line = @line = @customer.visits.hand_over.first.lines.detect {|x| x.class.to_s == "ItemLine"}
  item = @ip.items.detect {|x| x.model == @item_line.model}
  @selected_items = [item]
  @line_element = find(".line[data-id='#{@item_line.id}']")
  @line_element.find(".inventory_code input").set item.inventory_code
  @line_element.find(".inventory_code input").native.send_key(:enter)
  wait_until(15){ @line_element.has_xpath?(".[contains(@class, 'assigned')]") }
  @line_element.find(".select input").click
end

Then /^I see a summary of the things I selected for hand over$/ do
  @selected_items.each do |item|
    find(".dialog").should have_content(item.model.name)
  end
end

When /^I click hand over$/ do
  find("#hand_over_button").click
end

When /^I click hand over inside the dialog$/ do
  page.execute_script ("window.print = function(){return true;}")
  wait_until { find ".dialog .button" }
  find(".dialog .button", :text => "Hand Over").click
  wait_until(10){ find(".dialog .documents") }
end

Then /^the contract is signed for the selected items$/ do
  to_take_back_lines = @customer.visits.take_back.flat_map &:contract_lines
  @selected_items.each do |item|
    to_take_back_lines.map(&:item).include?(item).should be_true
  end
end

When /^I select an item without assigning an inventory code$/ do
  @item_line = @customer.visits.hand_over.first.lines.detect {|x| x.class.to_s == "ItemLine"}
  @line_element = find(".line[data-id='#{@item_line.id}']")
  @line_element.find(".select input").click
end

Then /^I got an error that i have to assign all selected item lines$/ do
  find(".notification").should have_content("unassigned")
end

When /^I change the contract lines time range to tomorrow$/ do
  step 'I open the booking calendar for this line'
  @new_start_date = @line.start_date + 1.day
  wait_until { find(".fc-widget-content .fc-day-number") }
  @new_start_date_element = get_fullcalendar_day_element(@new_start_date, @line)
  @new_start_date_element.click
  find("a", :text => "Start Date").click
  step 'I save the booking calendar'
end

Then /^I see that the time range in the summary starts today$/ do
  find(".summary .date").should have_content("#{Date.today.strftime("%d.%m.%Y")} -")
end

Then /^the lines start date is today$/ do
  @line.reload
  @line.start_date.should == Date.today
end

When /^I open a hand over with overdue lines$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|u| u.contracts.unsigned.count > 0 and u.contracts.unsigned.any?{|c| c.lines.any?{|l| l.start_date < Date.today}}}
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#hand_over", :visible => true)
end

When /^I select an overdue item line and assign an inventory code$/ do
  @item_line = @line = @customer.visits.hand_over.detect{|v| v.date < Date.today}.lines.detect {|x| x.class.to_s == "ItemLine"}
  item = @ip.items.detect {|x| x.model == @item_line.model}
  @selected_items = [item]
  @line_element = find(".line[data-id='#{@item_line.id}']")
  @line_element.find(".inventory_code input").set item.inventory_code
  @line_element.find(".inventory_code input").native.send_key(:enter)
  wait_until(15){ @line_element.has_xpath?(".[contains(@class, 'assigned')]") }
  @line_element.find(".select input").click
end