# -*- encoding : utf-8 -*-

When /^I open a hand over$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|x| x.contracts.unsigned.exists? }
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#hand_over", :visible => true)
end

When /^I select an item line and assign an inventory code$/ do
  @item_line = @line = @customer.visits.hand_over.first.lines.detect {|x| x.class.to_s == "ItemLine" and x.item_id.nil? }
  step 'I assign an inventory code the item line'
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
  page.execute_script ("window.print = function(){window.printed = 1; return true;}")
  wait_until { find ".dialog .button" }
  sleep(0.5)
  find(".dialog .button", :text => /(Hand Over|Aushändigen)/).click
  wait_until(20){ find(".dialog .documents") }
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
  find(".notification").should have_content("keine Inventarcodes zugewiesen") # Pius has his system set to German
end

When /^I change the contract lines time range to tomorrow$/ do
  step 'I open the booking calendar for this line'
  @new_start_date = if @line.start_date + 1.day < Date.today
      Date.today
    else
      @line.start_date + 1.day
  end
  wait_until { find(".fc-widget-content .fc-day-number") }
  @new_start_date_element = get_fullcalendar_day_element(@new_start_date)
  puts "@new_start_date = #{@new_start_date}"
  puts "@new_start_date_element = #{@new_start_date_element.text}"
  @new_start_date_element.click
  wait_until{ find("a", :text => /(Start Date|Startdatum)/) }
  find("a", :text => /(Start Date|Startdatum)/).click
  step 'I save the booking calendar'
end

Then /^I see that the time range in the summary starts today$/ do
  wait_until { find(".summary .date") }
  find(".summary .date").should have_content("#{Date.today.strftime("%d.%m.%Y")}")
  sleep(0.5)
end

Then /^the lines start date is today$/ do
  @line.reload.start_date.should == Date.today
end

When /^I open a hand over with overdue lines$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|u| u.contracts.unsigned.exists? and u.contracts.unsigned.any?{|c| c.lines.any?{|l| l.start_date < Date.today}}}
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#hand_over", :visible => true)
end

When /^I select an overdue item line and assign an inventory code$/ do
  @item_line = @line = @customer.visits.hand_over.detect{|v| v.date < Date.today}.lines.detect {|x| x.class.to_s == "ItemLine"}
  step 'I assign an inventory code the item line'
end

When /^I assign an inventory code the item line$/ do
  item = @ip.items.in_stock.where(model_id: @item_line.model).first
  @selected_items = [item]
  find(".line[data-id='#{@item_line.id}'] .inventory_code input").set item.inventory_code
  find(".line[data-id='#{@item_line.id}'] .inventory_code input").native.send_key(:enter)
  wait_until { find(".line[data-id='#{@item_line.id}']").has_xpath?(".[contains(@class, 'assigned')]") and find(".line[data-id='#{@item_line.id}'] .select input").checked? }
end

Then /^wird die Adresse des Verleihers aufgeführt$/ do
  find(".parties .inventory_pool .name")
end