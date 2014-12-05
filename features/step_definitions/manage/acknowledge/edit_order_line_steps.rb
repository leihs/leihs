# -*- encoding : utf-8 -*-

When /^I open a contract for acknowledgement( with more then one line)?(, whose start date is not in the past)?$/ do |arg1, arg2|
  contracts = @current_inventory_pool.contracts.submitted
  contracts = contracts.select {|c| c.lines.size > 1 and c.lines.map(&:model_id).uniq.size > 1 } if arg1
  contracts = contracts.select {|c| c.min_date >= Date.today} if arg2

  @contract = contracts.sample
  expect(@contract).not_to be_nil

  @customer = @contract.user

  step "I edit this submitted contract"
  expect(has_selector?("[data-order-approve]", :visible => true)).to be true
end

When /^I open the booking calendar for this line$/ do
  el = @line_element || find(@line_element_css)
  within el do
    find(".line-actions [data-edit-lines]").click
  end
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
  find("#submit-booking-calendar").click
end

Then /^the booking calendar is( not)? closed$/ do |arg1|
  b = !arg1
  expect(has_no_selector?("#submit-booking-calendar")).to be b
  expect(has_no_selector?("#booking-calendar")).to be b
end

When /^I change a contract lines time range$/ do
  @line = if @contract
    @contract.lines.sample
  else
    @customer.visits.where(inventory_pool_id: @current_inventory_pool).hand_over.first.lines.sample
  end
  @line_element = all(".line[data-ids*='#{@line.id}']").first || all(".line[data-id='#{@line.id}']").first
  step 'I open the booking calendar for this line'
  @new_start_date = if @line.start_date + 1.day < Date.today
      Date.today
    else
      @line.start_date + 1.day
  end
  expect(has_selector?(".fc-widget-content .fc-day-number")).to be true
  get_fullcalendar_day_element(@new_start_date).click
  find("#set-start-date", :text => _("Start Date")).click
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
end

Then /^the time range of that line is changed$/ do
  expect(@line.reload.start_date).to eq @new_start_date
end

When /^I increase a submitted contract lines quantity$/ do
  expect(has_selector?(".line[data-ids]")).to be true
  @line_element ||= all(".line[data-ids]").to_a.sample
  within @line_element do
    @line_model_name = find(".col6of10 strong").text
    @new_quantity = find("div:nth-child(3) > span:nth-child(1)").text.to_i + 1
  end
  step 'I change a contract lines quantity'
end

When /^I decrease a submitted contract lines quantity$/ do
  @line_element = all(".line[data-ids]").detect {|l| l.find("div:nth-child(3) > span:nth-child(1)").text.to_i > 1 }
  within @line_element do
    @line_model_name = find(".col6of10 strong").text
    @new_quantity = find("div:nth-child(3) > span:nth-child(1)").text.to_i - 1
  end
  step 'I change a contract lines quantity'
end

When /^I change a contract lines quantity$/ do
  if @line_element.nil? and page.has_selector?("#hand-over-view")
    @line = if @contract
              @contract.lines.sample
            else
              @customer.visits.where(inventory_pool_id: @current_inventory_pool).hand_over.first.lines.sample
            end
    @total_quantity = @line.contract.lines.where(:model_id => @line.model_id).sum(&:quantity)
    @new_quantity = @line.quantity + 1
    @line_element = find(".line[data-id='#{@line.id}']")
  end
  @line_element_css ||= ".line[data-ids*='#{@line.id}']" if @line
  @line_element ||= all(@line_element_css).first
  @line_ids = @line_element["data-ids"]
  step 'I open the booking calendar for this line'
  find("input#booking-calendar-quantity", match: :first).set @new_quantity
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
  find("#status .icon-ok")
end

Then(/^the contract line was duplicated$/) do
  expect(@line.contract.lines.where(:model_id => @line.model_id).sum(&:quantity)).to eq @total_quantity + 1
end

Then /^the quantity of that submitted contract line is changed$/ do
  JSON.parse(@line_ids).detect do |id|
    if has_selector?(".line[data-ids*='#{id}']", :text => @line_model_name)
      @line_element = find(".line[data-ids*='#{id}']", :text => @line_model_name)
    end
  end
  expect(@line_element).not_to be_nil
  @line_element.find("div:nth-child(3) > span:nth-child(1)", text: @new_quantity)
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
  @new_start_date = [@line1.start_date, Date.today].max + 2.days
  get_fullcalendar_day_element(@new_start_date).click
  find("#set-start-date", :text => _("Start Date")).click
  step 'I save the booking calendar'
  step 'the booking calendar is closed'
end

Then /^the time range for that lines is changed$/ do
  expect(@line1.reload.start_date).to eq @line2.reload.start_date
  expect(@line1.reload.start_date).to eq @new_start_date
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
  expect(has_selector?("#booking-calendar .fc-day-content")).to be true
end

When /^I change the time range for multiple lines that have quantity bigger then (\d+)$/ do |arg1|
  expect(has_selector?(".line[data-ids]")).to be true
  all_ids = all(".line[data-ids]").to_a.map {|x| x["data-ids"]}
  @models_quantities = all_ids.map do |ids|
    @line_element = find(".line[data-ids='#{ids}']")
    step 'I increase a submitted contract lines quantity'
    step 'the quantity of that submitted contract line is changed'
    expect(@new_quantity).to be > arg1.to_i
    {name: @line_model_name, quantity: @new_quantity}
  end
  expect(@models_quantities.size).to be > 0
  step 'I change the time range for multiple lines'
end

Then /^the quantity is not changed after just moving the lines start and end date$/ do
  @models_quantities.each do |x|
    line_element = find(".line", match: :prefer_exact, :text => x[:name])
    expect(line_element.find("div:nth-child(3) > span:nth-child(1)").text.to_i).to eq x[:quantity]
  end
end
