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