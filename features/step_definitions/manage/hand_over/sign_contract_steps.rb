# -*- encoding : utf-8 -*-

When /^I open a hand over( with at least one unassigned line for today)?( with options)?$/ do |arg1, arg2|
  @current_inventory_pool = @current_user.managed_inventory_pools.detect do |ip|
    @customer = ip.users.to_a.shuffle.detect do |user|
      b = user.visits.hand_over.exists?
      b = if arg1
            b and user.visits.hand_over.any?{|v| v.lines.size >= 3 and v.lines.any? {|l| not l.item and l.start_date == ip.next_open_date(Date.today)}}
          elsif arg2
            b and user.visits.hand_over.any?{|v| v.lines.any? {|l| l.is_a? OptionLine}}
          else
            b and user.visits.hand_over.any?{|v| v.lines.size >= 3 }
          end
      b
    end
  end
  raise "customer not found" unless @customer
  visit manage_hand_over_path(@current_inventory_pool, @customer)
  expect(has_selector?("#hand-over-view", :visible => true)).to be true
  @contract = @customer.contracts.approved.first
end

When /^I select (an item|a license) line and assign an inventory code$/ do |arg1|
  sleep(0.33)
  @models_in_stock = @current_inventory_pool.items.in_stock.map(&:model).uniq
  lines = @customer.visits.hand_over.flat_map(&:lines)

  @item_line = @line = case arg1
                         when "an item"
                           lines.detect {|l| l.class.to_s == "ItemLine" and l.item_id.nil? and @models_in_stock.include? l.model }
                         when "a license"
                           lines.detect {|l| l.class.to_s == "ItemLine" and l.item_id.nil? and @models_in_stock.include? l.model and l.model.is_a? Software }
                         else
                           raise "not found"
                       end
  expect(@item_line).not_to be nil
  step 'I assign an inventory code the item line'
  find(".button[data-edit-lines][data-ids='[#{@item_line.id}]']").click
  step "ich setze das Startdatum im Kalendar auf '#{I18n.l(Date.today)}'"
  find("#submit-booking-calendar").click
  find(".button[data-edit-lines][data-ids='[#{@item_line.id}]']")
  sleep(0.33)
end

Then /^I see a summary of the things I selected for hand over$/ do
  within(".modal") do
    @selected_items.each do |item|
      expect(has_content?(item.model.name)).to be true
    end
  end
end

When /^I click hand over$/ do
  expect(page).to have_no_selector ".button[data-hand-over-selection][disabled]"
  find(".button[data-hand-over-selection]").click
end

When /^I click hand over inside the dialog$/ do
  find(".modal .button.green[data-hand-over]", :text => _("Hand Over")).click
  check_printed_contract(page.driver.browser.window_handles)
end

Then /^the contract is signed for the selected items$/ do
  sleep(0.33)
  to_take_back_lines = @customer.visits.take_back.flat_map &:contract_lines
  to_take_back_items = to_take_back_lines.map(&:item)
  @selected_items.each do |item|
    expect(to_take_back_items.include?(item)).to be true
  end
end

When /^I select an item without assigning an inventory code$/ do
  @item_line = @customer.visits.hand_over.first.lines.detect {|x| x.class.to_s == "ItemLine"}
  find(".line[data-id='#{@item_line.id}'] input[type='checkbox'][data-select-line]", :visible => true).click
end

Then /^I got an error that i have to assign all selected item lines$/ do
  expect(find("#flash .error").has_content?(_ "you cannot hand out lines with unassigned inventory codes")).to be true
end

When /^I change the contract lines time range to tomorrow$/ do
  step 'I open the booking calendar for this line'
  @new_start_date = if @line.start_date + 1.day < Date.today
    Date.today
  else
    @line.start_date + 1.day
  end
  expect(has_selector?(".fc-widget-content .fc-day-number")).to be true
  @new_start_date_element = get_fullcalendar_day_element(@new_start_date)
  puts "@new_start_date = #{@new_start_date}"
  puts "@new_start_date_element = #{@new_start_date_element.text}"
  @new_start_date_element.click
  find("a", match: :first, :text => /(Start Date|Startdatum)/).click
  step 'I save the booking calendar'
end

Then /^I see that the time range in the summary starts today$/ do
  all(".modal-body > div > div > div > p").each do |date_range|
    expect(date_range.has_content?("#{Date.today.strftime("%d.%m.%Y")}")).to be true
  end
  sleep(0.33)
end

Then /^the lines start date is today$/ do
  sleep(0.33)
  expect(@line.reload.start_date).to eq Date.today
end

When /^I open a hand over with overdue lines$/ do
  @models_in_stock = @current_inventory_pool.items.in_stock.map(&:model).uniq
  @customer = @current_inventory_pool.users.to_a.detect do |u|
    u.contracts.approved.exists? and u.contracts.approved.any? do |c|
      c.lines.any? {|l| l.start_date < Date.today and l.end_date >= Date.today and @models_in_stock.include? l.model}
    end
  end
  expect(@customer).not_to be nil
  visit manage_hand_over_path(@current_inventory_pool, @customer)
  expect(has_selector?("#hand-over-view", :visible => true)).to be true
end

When /^I select an overdue item line and assign an inventory code$/ do
  @item_line = @line = @customer.visits.hand_over.detect{|v| v.date < Date.today}.lines.detect {|l| l.class.to_s == "ItemLine" and @models_in_stock.include? l.model}
  expect(@item_line).not_to be nil
  step 'I assign an inventory code the item line'
end

When /^I assign an inventory code the item line$/ do
  item = @current_inventory_pool.items.in_stock.where(model_id: @item_line.model).first
  expect(item).not_to be nil
  @selected_items ||= []
  within(".line[data-id='#{@item_line.id}']") do
    find("input[data-assign-item]").set item.inventory_code
    find("a.ui-corner-all", text: item.inventory_code)
    find("input[data-assign-item]").native.send_key(:enter)
  end
  line_selected = first(".line[data-id='#{@item_line.id}'].green")
  @selected_items << item if line_selected
end

Then /^wird die Adresse des Verleihers aufgeführt$/ do
  expect(has_selector?(".parties .inventory_pool .name")).to be true
end
