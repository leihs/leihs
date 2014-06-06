# -*- encoding : utf-8 -*-

When /^I open a contract for acknowledgement( with more then one line)?$/ do |arg1|
  if arg1
    @ip = @current_user.managed_inventory_pools.detect do |ip|
      @customer = ip.users.shuffle.detect {|x| x.contracts.submitted.exists? and x.contracts.submitted.first.lines.size > 1 }
    end
    raise "customer not found" unless @customer
    @models_in_stock = @ip.items.by_responsible_or_owner_as_fallback(@ip).in_stock.map(&:model).uniq
    @contract = @customer.contracts.submitted.detect{|v| v.lines.select{|l| !l.item and @models_in_stock.include? l.model}.count >= 2 }
  else
    @ip = @current_user.managed_inventory_pools.detect do |ip|
      @customer = ip.users.shuffle.detect {|x| x.contracts.submitted.exists? }
    end
    raise "customer not found" unless @customer
    @contract = @customer.contracts.submitted.first
  end
  visit manage_edit_contract_path(@ip, @contract)
  page.should have_selector("[data-order-approve]", :visible => true)
end

When /^I open the booking calendar for this line$/ do
  begin
    el = @line_element
  rescue # fix 'Element not found in the cache'
    el = find(@line_element_css)
  end
  el.find("[data-edit-lines]").click
  step "I see the booking calendar"
end

When /^I edit the timerange of the selection$/ do
  if page.has_selector?(".button.green[data-hand-over-selection]") or page.has_selector?(".button.green[data-take-back-selection]")
    step 'ich editiere alle Linien'
  else
    find(".multibutton [data-selection-enabled][data-edit-lines='selected-lines']", :text => _("Edit Selection")).click
  end
  step "I see the booking calendar"
end

When /^I save the booking calendar$/ do
  find("#submit-booking-calendar", :text => _("Save")).click
  sleep(0.33)
  page.should_not have_selector("#submit-booking-calendar", :text => _("Save"))
  page.should_not have_selector("#booking-calendar")
end

When /^I change a contract lines time range$/ do
  @line = if @contract
    @contract.lines.sample
  else
    @customer.visits.hand_over.first.lines.sample
  end
  @line_element = all(".line[data-ids*='#{@line.id}']").first
  @line_element ||= all(".line[data-id='#{@line.id}']").first
  step 'I open the booking calendar for this line'
  @new_start_date = if @line.start_date + 1.day < Date.today
      Date.today
    else
      @line.start_date + 1.day
  end
  page.should have_selector(".fc-widget-content .fc-day-number")
  get_fullcalendar_day_element(@new_start_date).click
  find("#set-start-date", :text => _("Start Date")).click
  step 'I save the booking calendar'
end

Then /^the time range of that line is changed$/ do
  @line.reload.start_date.should == @new_start_date
end

When /^I increase a submitted contract lines quantity$/ do
  page.should have_selector(".line[data-ids]")
  @line_element ||= all(".line[data-ids]").to_a.sample
  @line_model_name = @line_element.find(".col6of10 strong").text
  @new_quantity = @line_element.find("div:nth-child(3) > span:nth-child(1)").text.to_i + 1
  step 'I change a contract lines quantity'
end

When /^I decrease a submitted contract lines quantity$/ do
  @line_element = all(".line[data-ids]").detect {|l| l.find("div:nth-child(3) > span:nth-child(1)").text.to_i > 1 }
  @line_model_name = @line_element.find(".col6of10 strong").text
  @new_quantity = @line_element.find("div:nth-child(3) > span:nth-child(1)").text.to_i - 1
  step 'I change a contract lines quantity'
end

When /^I change a contract lines quantity$/ do
  if @line_element.nil? and page.has_selector?("#hand-over-view")
    @line = if @contract
              @contract.lines.sample
            else
              @customer.visits.hand_over.first.lines.sample
            end
    @total_quantity = @line.contract.lines.where(:model_id => @line.model_id).sum(&:quantity)
    @new_quantity = @line.quantity + 1
    @line_element = find(".line[data-id='#{@line.id}']")
  end
  @line_element_css ||= ".line[data-ids*='#{@line.id}']" if @line
  @line_element ||= all(@line_element_css).first
  step 'I open the booking calendar for this line'
  find("input#booking-calendar-quantity", match: :first).set @new_quantity
  step 'I save the booking calendar'
  find("#status .icon-ok")
end

Then(/^the contract line was duplicated$/) do
  @line.contract.lines.where(:model_id => @line.model_id).sum(&:quantity).should == @total_quantity + 1
end

Then /^the quantity of that submitted contract line is changed$/ do
  @line_element = find(".line", match: :prefer_exact, :text => @line_model_name)
  @line_element.find("div:nth-child(3) > span:nth-child(1)").text.should == @new_quantity.to_s
end

When /^I select two lines$/ do
  @line1 = @contract.lines.first
  find(".line", match: :prefer_exact, :text => @line1.model.name).find("input[type=checkbox]").set(true)
  @line2 = @contract.lines.detect {|l| l.model != @line1.model }
  find(".line", match: :prefer_exact, :text => @line2.model.name).find("input[type=checkbox]").set(true)
end

When /^I change the time range for multiple lines$/ do
  step 'I select two lines'
  step 'I edit the timerange of the selection'
  @new_start_date = @line1.start_date + 2.days
  get_fullcalendar_day_element(@new_start_date).click
  find("#set-start-date", :text => _("Start Date")).click
  step 'I save the booking calendar'
end

Then /^the time range for that lines is changed$/ do
  @line1.reload.start_date.should == @line2.reload.start_date 
  @line1.reload.start_date.should == @new_start_date
end

When /^I close the booking calendar$/ do
  find(".modal .modal-header .modal-close", text: _("Cancel")).click
end

When /^I edit one of the selected lines$/ do
  all(".line").each do |line|
    if line.find("input", match: :first).checked?
      @line_element = line
    end
  end
  step 'I open the booking calendar for this line'
end

Then /^I see the booking calendar$/ do
  page.should have_selector("#booking-calendar .fc-day-content")
end

When /^I change the time range for multiple lines that have quantity bigger then (\d+)$/ do |arg1|
  page.should have_selector(".line[data-ids]")
  all_ids = all(".line[data-ids]").to_a.map {|x| x["data-ids"]}
  @models_quantities = all_ids.map do |ids|
    @line_element = find(".line[data-ids='#{ids}']")
    step 'I increase a submitted contract lines quantity'
    step 'the quantity of that submitted contract line is changed'
    @new_quantity.should > arg1.to_i
    {name: @line_model_name, quantity: @new_quantity}
  end
  @models_quantities.size.should > 0
  step 'I change the time range for multiple lines'
end

Then /^the quantity is not changed after just moving the lines start and end date$/ do
  @models_quantities.each do |x|
    line_element = find(".line", match: :prefer_exact, :text => x[:name])
    line_element.find("div:nth-child(3) > span:nth-child(1)").text.to_i.should == x[:quantity]
  end
end
