# -*- encoding : utf-8 -*-

When(/^I open a hand over( with at least one unassigned line)?( for today)?( with options| with models)?$/) do |unassigned_line, for_today, with_options_or_models|
  @current_inventory_pool = @current_user.inventory_pools.managed.detect do |ip|

    @customer = ip.users.not_as_delegations.order("RAND ()").detect do |user|
      if unassigned_line and for_today
        user.visits.hand_over.any?{|v| v.lines.size >= 3 and v.lines.any? {|l| not l.item and l.start_date == ip.next_open_date(Date.today)}}
      elsif for_today 
        user.visits.hand_over.find {|ho| ho.date == Date.today}
      elsif with_options_or_models
        user.visits.hand_over.any?{|v| v.lines.any? do |l|
          l.is_a?(case with_options_or_models
                    when " with options"
                      OptionLine
                    when " with models"
                      ItemLine
                  end)
        end }
      else
        user.visits.hand_over.any?{|v| v.lines.size >= 3 }
      end
    end
  end
  expect(@customer).not_to be_nil

  step "I open a hand over for this customer"
  expect(has_selector?("#hand-over-view", :visible => true)).to be true

  @contract = @customer.reservations_bundles.where(inventory_pool_id: @current_inventory_pool).approved.first
end

When /^I open a hand over which has multiple( unassigned)? lines( and models in stock)?( with software)?$/ do |arg1, arg2, arg3|
  @hand_over = if arg1
                 if arg2
                   @models_in_stock = @current_inventory_pool.items.in_stock.map(&:model).uniq
                   @current_inventory_pool.visits.hand_over.detect { |v|
                     b = v.lines.select { |l| !l.item and @models_in_stock.include? l.model }.count >= 2
                     if arg3
                       (b and !!v.lines.detect {|cl| cl.model.is_a? Software })
                     else
                       b
                     end
                   }
                 else
                   @current_inventory_pool.visits.hand_over.detect { |x| x.lines.select { |l| !l.item }.count >= 2 }
                 end
               else
                 @current_inventory_pool.visits.hand_over.detect { |x| x.lines.size > 1 }
               end
  expect(@hand_over).not_to be_nil

  @customer = @hand_over.user
  step "I open a hand over for this customer"
  expect(has_selector?("#hand-over-view", :visible => true)).to be true
end

When /^I open a hand over with lines that have assigned inventory codes$/ do
  steps %Q{
    When I open a hand over which has multiple unassigned lines and models in stock
     And I click an inventory code input field of an item line
    Then I see a list of inventory codes of items that are in stock and matching the model
    When I select one of those
    Then the item line is assigned to the selected inventory code
  }
end

When /^I open a hand over with overdue lines$/ do
  @models_in_stock = @current_inventory_pool.items.in_stock.map(&:model).uniq
  @customer = @current_inventory_pool.users.to_a.detect do |u|
    u.reservations_bundles.approved.exists? and u.reservations_bundles.approved.any? do |c|
      c.lines.any? {|l| l.start_date < Date.today and l.end_date >= Date.today and @models_in_stock.include? l.model}
    end
  end
  expect(@customer).not_to be_nil
  step "I open a hand over for this customer"
end



When /^I select (an item|a license) line and assign an inventory code$/ do |arg1|
  @models_in_stock = @current_inventory_pool.items.in_stock.map(&:model).uniq
  lines = @customer.visits.hand_over.where(inventory_pool_id: @current_inventory_pool).flat_map(&:lines)

  @item_line = @line = case arg1
                         when "an item"
                           lines.detect {|l| l.class.to_s == "ItemLine" and l.item_id.nil? and @models_in_stock.include? l.model }
                         when "a license"
                           lines.detect {|l| l.class.to_s == "ItemLine" and l.item_id.nil? and @models_in_stock.include? l.model and l.model.is_a? Software }
                         else
                           raise
                       end
  expect(@item_line).not_to be_nil
  step 'I assign an inventory code to the item line'
  find(".button[data-edit-lines][data-ids='[#{@item_line.id}]']").click
  step "I set the start date in the calendar to '#{I18n.l(Date.today)}'"
  step "I save the booking calendar"
  find(".button[data-edit-lines][data-ids='[#{@item_line.id}]']")
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
  within ".modal" do
    find(".button.green[data-hand-over]", text: _("Hand Over")).click
  end
  check_printed_contract(page.driver.browser.window_handles)
end

Then /^the contract is signed for the selected items$/ do
  @reservations_to_take_back = @customer.reservations.signed.where(inventory_pool_id: @current_inventory_pool)
  to_take_back_items = @reservations_to_take_back.map(&:item)
  @selected_items.each do |item|
    expect(to_take_back_items.include?(item)).to be true
  end
  lines = @selected_items.map do |item|
    @reservations_to_take_back.find_by(item_id: item)
  end
  expect(lines.map(&:contract).uniq.size).to be 1
  @contract = @customer.reservations_bundles.signed.where(inventory_pool_id: @current_inventory_pool).detect {|reservations_bundle| reservations_bundle.lines.include? lines.first}
end

When /^I select an item without assigning an inventory code$/ do
  @item_line = @customer.visits.hand_over.where(inventory_pool_id: @current_inventory_pool).first.lines.detect {|l| l.is_a?(ItemLine) and not l.item }
  find(".line[data-id='#{@item_line.id}'] input[type='checkbox'][data-select-line]", :visible => true).click
end

Then /^I got an error that i have to assign all selected item lines$/ do
  find("#flash .error", text: _("you cannot hand out lines with unassigned inventory codes"))
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
  find("a", match: :first, :text => _("Start date")).click
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
end

Then /^I see that the time range in the summary starts today$/ do
  all(".modal-body > div > div > div > p").each do |date_range|
    expect(date_range.has_content?("#{I18n.l Date.today}")).to be true
  end
end

Then /^the lines start date is today$/ do
  expect(@line.reload.start_date).to eq Date.today
end

When /^I select an overdue item line and assign an inventory code$/ do
  @item_line = @line = @customer.visits.hand_over.where(inventory_pool_id: @current_inventory_pool).detect{|v| v.date < Date.today}.lines.detect {|l| l.class.to_s == "ItemLine" and @models_in_stock.include? l.model}
  expect(@item_line).not_to be_nil
  step 'I assign an inventory code to the item line'
end

When /^I assign an inventory code to the item line$/ do
  item = @current_inventory_pool.items.in_stock.where(model_id: @item_line.model).order("RAND()").first
  expect(item).not_to be_nil
  @selected_items ||= []
  within(".line[data-id='#{@item_line.id}']") do
    find("input[data-assign-item]").set item.inventory_code
    find(".ui-menu-item a", text: item.inventory_code)
    find("input[data-assign-item]").native.send_key(:enter)
  end
  line_selected = find(".line[data-id='#{@item_line.id}'].green")
  @selected_items << item if line_selected
end

Then /^wird die Adresse des Verleihers aufgeführt$/ do
  expect(has_selector?(".parties .inventory_pool .name")).to be true
end
