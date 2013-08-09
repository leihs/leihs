# -*- encoding : utf-8 -*-

When /^I delete a line$/ do
  @contract = @customer.contracts.unsigned.first
  @line = @contract.lines.first
  step 'I delete this line element'
end

When /^I delete this line element$/ do
  find(".line[data-id='#{@line.id}']").find(".multibutton .trigger").click
  find(".line[data-id='#{@line.id}']").find(".button", :text => /(Delete|Löschen)/).click
  sleep(0.6)
end

Then /^this line is deleted$/ do
  lambda {@line.reload}.should raise_error(ActiveRecord::RecordNotFound) 
end

When /^I select multiple lines$/ do
  @selected_lines = @hand_over.lines.map do |line|
    line = all(".line", :text => line.model.name).detect {|x| not x.find(".select input").checked?}
    line.find(".select input").click
    line
  end
end

When /^I delete the seleted lines$/ do
  page.execute_script('$("#selection_actions .multibutton .button").show()')
  find("#selection_actions .multibutton .button", :text => /(Delete|Löschen)/i).click
  step "ensure there are no active requests"
end

Then /^these lines are deleted$/ do
  (@selected_lines & all(".line")).should be_empty
  lambda {@hand_over.reload}.should raise_error(ActiveRecord::RecordNotFound)
  step 'the count matches the amount of selected lines'
end

When /^I delete all lines of a model thats availability is blocked by these lines$/ do
  if not @customer.contracts.unsigned.last.lines.first.available?
    step 'I add an item to the hand over by providing an inventory code and a date range'
    @model = Item.find_by_inventory_code(@inventory_code).model
    find(".line", :text => @model.name).find(".select input").click
  end
  step 'I add so many lines that I break the maximal quantity of an model'
  target_linegroup = find(".linegroup", :text => _("Today"))
  step "ensure there are no active requests"
  reference_line = all(".line.error", :text => @model.name).detect{|line| not line.find(".select input").checked?}
  @reference_id = reference_line["data-id"]

  line_ids = target_linegroup.all(".line.error", :text => @model.name).map{|line| line["data-id"]}
  line_ids.each do |id|
    if id != @reference_id
      all(".line").detect{|line| line["data-id"] == id}.find(".multibutton .trigger").click
      all(".line").detect{|line| line["data-id"] == id}.find(".button", :text => _("Delete")).click
      sleep(0.6)
    end
  end
end

Then /^the availability of the keeped line is updated$/ do
  reference_line = all(".line").detect{|line| line["data-id"] == @reference_id}
  reference_line[:class].match("error").should be_nil
end
