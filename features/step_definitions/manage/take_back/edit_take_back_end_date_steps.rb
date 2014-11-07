When /^I change (a contract|an option) line end date$/ do |arg1|
  line_el = case arg1
              when "an option"
                find(".line[data-line-type='option_line']", match: :first)
              else
                find(".line", match: :first)
            end
  @line = @contract_lines_to_take_back.find(line_el["data-id"])
  line_el.has_content?(@line.model.name)
  line_el.find(".multibutton .button", :text => _("Change entry")).click
  @old_start_date = @line.start_date
  @old_end_date = @line.end_date
  @new_end_date = [@old_end_date, Date.today].max + 1.day
  @new_end_date_element = get_fullcalendar_day_element(@new_end_date)
  @new_end_date_element.click
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
end

Then /^the end date of that line is changed$/ do
  expect(@line.reload.end_date).to eq @new_end_date
  expect(@line.reload.end_date).not_to eq @old_end_date
end

Then /^the start date of that line is not changed$/ do
  expect(@line.reload.start_date).to eq @old_start_date
end

When /^I open a take back which has multiple lines$/ do
  @customer = @current_inventory_pool.users.find {|x| x.contracts.signed.size > 0 and !x.contracts.signed.detect{|c| c.lines.size > 1 and c.inventory_pool == @current_inventory_pool}.nil? }
  @contract = @customer.contracts.signed.detect{|c| c.lines.size > 1 and c.inventory_pool == @current_inventory_pool}
  visit manage_take_back_path(@current_inventory_pool, @customer)
  expect(has_selector?("#take-back-view")).to be true
end

When /^I change the end date for all contract lines, envolving option and item lines$/ do
  step 'I select all lines'
  step 'I edit the timerange of the selection'
  @old_end_date = @contract.lines.map(&:end_date).max
  @new_end_date = @current_inventory_pool.next_open_date(@old_end_date + 1.day)
  @new_end_date_element = get_fullcalendar_day_element(@new_end_date)
  @new_end_date_element.click
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
end

Then /^the end date for all contract lines is changed$/ do
  @contract.reload.lines.each do |line|
    expect(line.end_date).to eq @new_end_date
    expect(line.end_date).not_to eq @old_end_date
  end
end
