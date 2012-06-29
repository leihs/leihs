When /^I delete a line of this order$/ do
  @line = @customer.contracts.unsigned.first.lines.first
  puts "??? @customer.contracts.unsigned.first = #{@customer.contracts.unsigned.first.id}"
  puts "??? @line.model.name = #{@line.model.name}"
  @line_element = find(".line", :text => @line.model.name)
  @line_element.find(".multibutton .trigger").click
  wait_until {@line_element.find(".button", :text => "Delete")}
  @line_element.find(".button", :text => "Delete").click
  wait_until { page.evaluate_script("$.active") == 0 }
end

Then /^this orderline is deleted$/ do
  @order.lines.include?(@line).should == false
end