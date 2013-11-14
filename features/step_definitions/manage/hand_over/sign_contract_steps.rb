# -*- encoding : utf-8 -*-

When /^I open a hand over$/ do
  @ip = @current_user.managed_inventory_pools.sample
  @customer = @ip.users.all.shuffle.detect {|c| c.visits.hand_over.exists? and c.visits.hand_over.any?{|v| v.lines.size >= 3}}
  raise "customer not found" unless @customer
  visit manage_hand_over_path(@ip, @customer)
  page.should have_selector("#hand-over-view", :visible => true)
end

When /^I select an item line and assign an inventory code$/ do
  sleep(0.88)
  @item_line = @line = @customer.visits.hand_over.flat_map(&:lines).detect {|x| x.class.to_s == "ItemLine" and x.item_id.nil? }
  step 'I assign an inventory code the item line'
end

Then /^I see a summary of the things I selected for hand over$/ do
  @selected_items.each do |item|
    first(".modal").should have_content(item.model.name)
  end
end

When /^I click hand over$/ do
  find("[data-hand-over-selection]").click
end

When /^I click hand over inside the dialog$/ do
  find(".modal .button.green[data-hand-over]", :text => _("Hand Over")).click
  check_printed_contract(page.driver.browser.window_handles)
end

Then /^the contract is signed for the selected items$/ do
  sleep(0.88)
  to_take_back_lines = @customer.visits.take_back.flat_map &:contract_lines
  to_take_back_items = to_take_back_lines.map(&:item)
  @selected_items.each do |item|
    to_take_back_items.include?(item).should be_true
  end
end

When /^I select an item without assigning an inventory code$/ do
  @item_line = @customer.visits.hand_over.first.lines.detect {|x| x.class.to_s == "ItemLine"}
  find(".line[data-id='#{@item_line.id}'] input[type='checkbox'][data-select-line]", :visible => true).click
end

Then /^I got an error that i have to assign all selected item lines$/ do
  find("#flash .error").has_content? _("you cannot hand out lines with unassigned inventory codes")
end

When /^I change the contract lines time range to tomorrow$/ do
  step 'I open the booking calendar for this line'
  @new_start_date = if @line.start_date + 1.day < Date.today
    Date.today
  else
    @line.start_date + 1.day
  end
  page.should have_selector(".fc-widget-content .fc-day-number")
  @new_start_date_element = get_fullcalendar_day_element(@new_start_date)
  puts "@new_start_date = #{@new_start_date}"
  puts "@new_start_date_element = #{@new_start_date_element.text}"
  @new_start_date_element.click
  first("a", :text => /(Start Date|Startdatum)/).click
  step 'I save the booking calendar'
end

Then /^I see that the time range in the summary starts today$/ do
  all(".modal-body > div > div > div > p").each do |date_range|
    date_range.should have_content("#{Date.today.strftime("%d.%m.%Y")}")
  end
  sleep(0.5)
end

Then /^the lines start date is today$/ do
  sleep(0.88)
  @line.reload.start_date.should == Date.today
end

When /^I open a hand over with overdue lines$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.all.detect {|u| u.contracts.approved.exists? and u.contracts.approved.any?{|c| c.lines.any?{|l| l.start_date < Date.today}}}
  visit manage_hand_over_path(@ip, @customer)
  page.has_css?("#hand-over-view", :visible => true)
end

When /^I select an overdue item line and assign an inventory code$/ do
  @item_line = @line = @customer.visits.hand_over.detect{|v| v.date < Date.today}.lines.detect {|x| x.class.to_s == "ItemLine"}
  step 'I assign an inventory code the item line'
end

When /^I assign an inventory code the item line$/ do
  item = @ip.items.in_stock.where(model_id: @item_line.model).first
  @selected_items ||= []
  @selected_items << item
  within(".line[data-id='#{@item_line.id}']") do
    find("[data-assign-item]").set item.inventory_code
    find("[data-assign-item]").native.send_key(:enter)
  end
  sleep(0.88)
end

Then /^wird die Adresse des Verleihers aufgeführt$/ do
  page.should have_selector(".parties .inventory_pool .name")
end
