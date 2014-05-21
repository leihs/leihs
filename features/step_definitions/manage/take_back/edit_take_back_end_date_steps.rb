When /^I change (a contract|an option) line end date$/ do |arg1|
  line_el = case arg1
              when "an option"
                all(".line[data-line-type='option_line']")
              else
                all(".line")
            end.to_a.sample
  @line = @contract_lines_to_take_back.find(line_el["data-id"])
  line_el.has_content?(@line.model.name)
  line_el.find(".multibutton .button", :text => _("Change entry")).click
  @old_start_date = @line.start_date
  @old_end_date = @line.end_date
  @new_end_date = [@old_end_date, Date.today].max + 1.day
  @new_end_date_element = get_fullcalendar_day_element(@new_end_date)
  @new_end_date_element.click
  step 'I save the booking calendar'
end

Then /^the end date of that line is changed$/ do
  @line.reload.end_date.should == @new_end_date
  @line.reload.end_date.should_not == @old_end_date
end

Then /^the start date of that line is not changed$/ do
  @line.reload.start_date.should == @old_start_date
end

When /^I open a take back which has multiple lines$/ do
  @ip = @current_user.managed_inventory_pools.first
  @customer = @ip.users.find {|x| x.contracts.signed.size > 0 && !x.contracts.signed.detect{|c| c.lines.size > 1 and c.inventory_pool == @ip}.nil? }
  @contract = @customer.contracts.signed.detect{|c| c.lines.size > 1 and c.inventory_pool == @ip}
  visit manage_take_back_path(@ip, @customer)
  page.should have_selector("#take-back-view")
end

When /^I change the end date for all contract lines, envolving option and item lines$/ do
  step 'I select all lines'
  step 'I edit the timerange of the selection'
  @line = @contract.lines.first
  @old_end_date = @line.end_date
  @new_end_date = [@line.start_date, Date.today].max + 1.day
  @new_end_date_element = get_fullcalendar_day_element(@new_end_date)
  @new_end_date_element.click
  step 'I save the booking calendar'
end

Then /^the end date for all contract lines is changed$/ do
  @contract.reload.lines.each do |line|
    line.end_date.should == @new_end_date
    line.end_date.should_not == @old_end_date
  end
end
