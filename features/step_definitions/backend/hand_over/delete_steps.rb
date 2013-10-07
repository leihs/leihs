# -*- encoding : utf-8 -*-

When /^I delete a line$/ do
  @contract = @customer.contracts.approved.first
  @line = @contract.lines.first
  step 'I delete this line element'
end

When /^I delete this line element$/ do
  find(".line[data-id='#{@line.id}']").first(".multibutton .trigger").click
  find(".line[data-id='#{@line.id}']").first(".button", :text => /(Delete|Löschen)/).click
end

Then /^this line is deleted$/ do
  step "ensure there are no active requests"
  lambda {@line.reload}.should raise_error(ActiveRecord::RecordNotFound) 
end

When /^I select multiple lines$/ do
  page.should_not have_selector(".line[data-id]")
  @selected_line_ids = @hand_over.lines.map do |line|
    page.should have_selector(".line", :text => line.model.name)
    line = all(".line", :text => line.model.name).detect {|x| not x.first(".select input").checked?}
    line.first(".select input").click
    line["data-id"]
  end
end

When /^I delete the seleted lines$/ do
  page.execute_script('$("#selection_actions .multibutton .button").show()')
  first("#selection_actions .multibutton .button", :text => /(Delete|Löschen)/i).click
  step "ensure there are no active requests"
end

Then /^these lines are deleted$/ do
  @selected_line_ids.each do |line_id|
    page.should_not have_selector(".line[data-id='#{line_id}']")
  end
  lambda {@hand_over.reload}.should raise_error(ActiveRecord::RecordNotFound)
  step 'the count matches the amount of selected lines'
end

When /^I delete all lines of a model thats availability is blocked by these lines$/ do
  if not @customer.contracts.approved.last.lines.first.available?
    step 'I add an item to the hand over by providing an inventory code and a date range'
    @model = Item.find_by_inventory_code(@inventory_code).model
    first(".line", :text => @model.name).first(".select input").click
  end
  step 'I add so many lines that I break the maximal quantity of an model'
  target_linegroup = first(".linegroup", :text => _("Today"))
  step "ensure there are no active requests"
  reference_line = all(".line.error", :text => @model.name).detect{|line| not line.first(".select input").checked?}
  @reference_id = reference_line["data-id"]

  line_ids = target_linegroup.all(".line.error", :text => @model.name).map{|line| line["data-id"]}
  line_ids.each do |id|
    if id != @reference_id
      find(".line[data-id='#{id}'] .multibutton .trigger").hover
      find(".line[data-id='#{id}'] .button", :text => _("Delete")).click
      sleep(0.6)
    end
  end
end

Then /^the availability of the keeped line is updated$/ do
  reference_line = all(".line").detect{|line| line["data-id"] == @reference_id}
  reference_line[:class].match("error").should be_nil
end
