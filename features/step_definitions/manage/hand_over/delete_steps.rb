# -*- encoding : utf-8 -*-

When /^I delete a line$/ do
  @contract = @customer.contracts.approved.find_by(inventory_pool_id: @current_inventory_pool)
  @line = @contract.lines.first
  step 'I delete this line element'
end

When /^I delete this line element$/ do
  within(".line[data-id='#{@line.id}']") do
    find(".dropdown-toggle").click
    find(".red[data-destroy-line]", :text => _("Delete")).click
  end
end

Then /^this line is deleted$/ do
  find(".line", match: :first)
  expect(has_no_selector?(".line[data-id='#{@line.id}']")).to be true
  expect { @line.reload }.to raise_error(ActiveRecord::RecordNotFound)
end

When /^I select multiple lines$/ do
  @selected_line_ids = @hand_over.lines.order("RAND()").limit(rand(1..@hand_over.lines.count)).map &:id
  expect(has_selector?(".line[data-id]", match: :first)).to be true
  @selected_line_ids.each do |id|
    cb = find(".line[data-id='#{id}'] input[type='checkbox'][data-select-line]")
    cb.click unless cb.checked?
  end
end

When /^I delete the seleted lines$/ do
  find(".multibutton .button[data-selection-enabled] + .dropdown-holder").click
  within(".multibutton .button[data-selection-enabled] + .dropdown-holder") do
    find(".dropdown-item.red[data-destroy-selected-lines]", text: _("Delete Selection")).click
  end
end

Then /^these lines are deleted$/ do
  @selected_line_ids.each do |line_id|
    expect(has_no_selector?(".line[data-id='#{line_id}']")).to be true
  end
  @selected_line_ids.each {|id| expect { ContractLine.find(id) }.to raise_error(ActiveRecord::RecordNotFound)}
end

When /^I delete all lines of a model thats availability is blocked by these lines$/ do
  unless @customer.contracts.approved.find_by(inventory_pool_id: @current_inventory_pool).lines.first.available?
    step 'I add an item to the hand over by providing an inventory code'
    @model = Item.find_by_inventory_code(@inventory_code).model
    find(".line", match: :prefer_exact, text: @model.name).find("input[type='checkbox'][data-select-line]").click
  end
  step 'I add so many lines that I break the maximal quantity of a model'
  step 'the availability is loaded'
  target_linegroup = find("[data-selected-lines-container]", text: /#{find("#add-start-date").value}.*#{find("#add-end-date").value}/)

  reference_line = target_linegroup.all(".line", :text => @model.name).detect{|line| line.find(".line-info.red")}
  @reference_id = reference_line["data-id"]

  line_ids = target_linegroup.all(".line", :text => @model.name).select{|line| line.find(".line-info.red")}.map{|line| line["data-id"]}
  line_ids.each do |id|
    if id != @reference_id
      find(".line[data-id='#{id}'] .multibutton .dropdown-toggle").click
      find(".line[data-id='#{id}'] .dropdown-item.red", :text => _("Delete")).click
        end
  end
end

Then /^the availability of the keeped line is updated$/ do
  reference_line = all(".line").detect{|line| line["data-id"] == @reference_id}
  expect(reference_line[:class].match("error")).to eq nil
end
