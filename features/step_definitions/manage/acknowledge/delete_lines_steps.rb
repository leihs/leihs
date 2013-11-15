# -*- encoding : utf-8 -*-


When(/^I open a contract for acknowledgement that has more then one line$/) do
  @ip = @current_user.managed_inventory_pools.first
  @contract = @ip.contracts.detect {|o| o.lines.length > 1}
  @customer = @contract.user
  visit manage_edit_contract_path(@ip, @contract)
  page.has_css?("#acknowledge", :visible => true)
end

When /^I delete a line of this contract$/ do
  @line = @contract.lines.first
  @line_element = find(".line", match: :prefer_exact, :text => @line.model.name)
  @line_element.find(".multibutton .dropdown-toggle").hover
  @line_element.find(".multibutton .red[data-destroy-lines]", :text => _("Delete")).click
end

Then /^this contractline is deleted$/ do
  sleep(0.88)
  @contract.lines.reload.include?(@line).should == false
end

When /^I delete multiple lines of this contract$/ do
  step 'I add a model by typing in the inventory code of an item of that model to the quick add'

  find("[data-selected-lines-container] input[data-select-lines]", match: :first).click
  find("[data-selected-lines-container] input[data-select-lines]", match: :first).click

  step 'I select two lines'
  step 'I delete the selection'
end

When /^I delete the selection$/ do
  line_amount_before = all(".line").size
  find(".multibutton [data-selection-enabled] + .dropdown-holder").hover
  find("a", :text => _("Delete Selection")).click
  step "ensure there are no active requests"
  all(".line").size.should < line_amount_before
end

Then /^these contractlines are deleted$/ do
  lambda {@line1.reload}.should raise_error(ActiveRecord::RecordNotFound)
  lambda {@line2.reload}.should raise_error(ActiveRecord::RecordNotFound)
end

When /^I delete all lines of this contract$/ do
  all(".line").each do |line|
    line.find("input[type=checkbox]").click
  end
  page.execute_script('$("#selection_actions .button").show()')
  find(".multibutton [data-selection-enabled] + .dropdown-holder").hover
  find("a", :text => _("Delete Selection")).click
  step "ensure there are no active requests"
end

Then /^I got an error message that not all lines can be deleted$/ do
  first(".notification")
  first(".error.notification")
end

Then /^none of the lines are deleted$/ do
  @contract.lines.count.should > 0
end
