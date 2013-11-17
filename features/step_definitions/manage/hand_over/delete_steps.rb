# -*- encoding : utf-8 -*-

When /^I delete a line$/ do
  @contract = @customer.contracts.approved.first
  @line = @contract.lines.first
  step 'I delete this line element'
end

When /^I delete this line element$/ do
  within(".line[data-id='#{@line.id}']") do
    find(".dropdown-toggle").hover
    find(".red[data-destroy-line]", :text => _("Delete")).click
  end
end

Then /^this line is deleted$/ do
  find(".line", match: :first)
  page.has_no_selector?(".line[data-id='#{@line.id}']").should be_true
  lambda {@line.reload}.should raise_error(ActiveRecord::RecordNotFound) 
end

When /^I select multiple lines$/ do
  find(".line[data-id]", match: :first)
  @selected_line_ids = @hand_over.lines.map do |line|
    find(".line", match: :first, :text => line.model.name)
    line = all(".line", :text => line.model.name).detect {|x| not x.find("input[type='checkbox'][data-select-line]").checked?}
    line.find("input[type='checkbox'][data-select-line]").click
    line["data-id"]
  end
end

When /^I delete the seleted lines$/ do
  within(".multibutton .button[data-selection-enabled] + .dropdown-holder") do
    find(".dropdown-toggle").hover
    find(".dropdown-item.red[data-destroy-selected-lines]", text: _("Delete Selection")).click
  end
  find(".line", match: :first)
end

Then /^these lines are deleted$/ do
  @selected_line_ids.each do |line_id|
    page.should_not have_selector(".line[data-id='#{line_id}']")
  end
  lambda {@hand_over.reload}.should raise_error(ActiveRecord::RecordNotFound)
  step 'the count matches the amount of selected lines'
end

When /^I delete all lines of a model thats availability is blocked by these lines$/ do
  unless @customer.contracts.approved.last.lines.first.available?
    step 'I add an item to the hand over by providing an inventory code and a date range'
    @model = Item.find_by_inventory_code(@inventory_code).model
    find(".line", match: :prefer_exact, text: @model.name).find("input[type='checkbox'][data-select-line]").click
  end
  step 'I add so many lines that I break the maximal quantity of an model'
  target_linegroup = find("[data-selected-lines-container]", text: /#{find("#add-start-date").value}.*#{find("#add-end-date").value}/)

  reference_line = target_linegroup.all(".line", :text => @model.name).detect{|line| line.find(".line-info.red")}
  @reference_id = reference_line["data-id"]

  line_ids = target_linegroup.all(".line", :text => @model.name).select{|line| line.find(".line-info.red")}.map{|line| line["data-id"]}
  line_ids.each do |id|
    if id != @reference_id
      find(".line[data-id='#{id}'] .multibutton .dropdown-toggle").hover
      find(".line[data-id='#{id}'] .dropdown-item.red", :text => _("Delete")).click
      sleep(0.6)
    end
  end
end

Then /^the availability of the keeped line is updated$/ do
  reference_line = all(".line").detect{|line| line["data-id"] == @reference_id}
  reference_line[:class].match("error").should be_nil
end
