When /^I delete a line of this order$/ do
  @line = @customer.contracts.unsigned.first.lines.first
  @line_element = find(".line", :text => @line.model.name)
  @line_element.find(".multibutton .trigger").click
  wait_until {@line_element.find(".button", :text => "Delete")}
  @line_element.find(".button", :text => "Delete").click
  wait_until{
    all(".line", :text => @line.model.name).size == 0
  }
end

Then /^this orderline is deleted$/ do
  @order.lines.include?(@line).should == false
end

When /^I delete multiple lines of this order$/ do
  step 'I add a model by typing in the inventory code of an item of that model to the quick add'
  step 'I select two lines'
  step 'I delete the selection'
end

When /^I delete the selection$/ do
  page.execute_script('$("#selection_actions .button").show()')
  line_amount_before = all(".line").size
  find(".button", :text => "Delete").click
  wait_until { all(".line").size < line_amount_before }
end

Then /^these orderlines are deleted$/ do
  lambda {@line1.reload}.should raise_error(ActiveRecord::RecordNotFound)
  lambda {@line2.reload}.should raise_error(ActiveRecord::RecordNotFound)
end

When /^I delete all lines of this order$/ do
  all(".line").each do |line|
    line.find("input[type=checkbox]").click
  end
  page.execute_script('$("#selection_actions .button").show()')
  line_amount_before = all(".line").size
  find(".button", :text => "Delete").click
end

Then /^I got an error message that not all lines can be deleted$/ do
  wait_until {find(".notification")}
  find(".notification").should have_content "You cannot delete all lines of an order, you might want to reject?"
end

Then /^none of the lines are deleted$/ do
  @order.lines.count.should > 0
end
